import tensorflow as tf
from tensorflow.core.framework import op_def_pb2
from google.protobuf import text_format
from termcolor import colored
import re
import textwrap

ops = op_def_pb2.OpList()
text_format.Merge(open('ops.pbtxt').read(), ops)

data_type_name = [
    '',
    'FLOAT',
    'DOUBLE',
    'INT32',
    'UINT8',
    'INT16',
    'INT8',
    'STRING',
    'COMPLEX64',
    'COMPLEX',
    'INT64',
    'BOOL',
    'QINT8',
    'QUINT8',
    'QINT32',
    'BFLOAT16',
    'QINT16',
    'QUINT16',
    'UINT16',
    'COMPLEX128',
    'HALF',
    'RESOURCE',
    'VARIANT',
    'UINT32',
    'UINT64'
]
lua_keywords = [
    'and', 'break', 'do', 'else', 'elseif', 'end', 'false', 'for', 'function', 'if', 'in', 'local', 'nil', 'not', 'or', 'repeat', 'return', 'then', 'true', 'until', 'while'
]
def proc_var_name(name):
    if name in lua_keywords:
        name += '_'
    return name

pattern_arg = '  Args:'
pattern_ret = '  Returns:'
def parse_tf_doc(tf_func_doc):
    lines = tf_func_doc.split('\n')
    doc = []
    arg = []
    ret = []
    meet_arg = False
    meet_ret = False
    for line in lines:
        if line == pattern_arg:
            meet_arg = True
            meet_ret = False
            continue
        if line == pattern_ret:
            meet_arg = False
            meet_ret = True
            continue
        if meet_arg and line != pattern_arg:
            indent = 0
            match = re.match('^\s+',line)
            if match:
                indent = match.span()[1]
            line = line.strip()
            pos = line.find(':')
            if pos > -1 and indent <= 4:
                arg_name = line[:pos]
                arg_doc = line[pos + 1:]
                arg.append([arg_name, [arg_doc]])
            elif len(arg):
                arg[-1][1].append(line)
            else:
                doc.append('--- ' + line)
        elif meet_ret and line != pattern_ret:
            ret.append(line.strip())
        else:
            doc.append('--- ' + line)
    arg_doc = {}
    for a in arg:
        arg_doc[a[0]] = ' '.join(a[1])
    ret_doc = ' '.join(ret)
    return '\n'.join(doc), arg_doc, ret_doc


class Attribute:
    def __init__(self, attr, number_attr_list):
        self.attr = attr
        self.name = self.attr.name
        self.var_name = proc_var_name(self.name.replace('template', 'template_arg'))

        # if self.attr.type == "func": raise Exception("Passing functions as arguments is not yet supported")

        # List attributes are defined as 'list(attr)''
        self.type, self.islist = (self.attr.type, False) if self.attr.type[:4] != 'list' else (self.attr.type[5:-1], True)

        self.number_attr = [i for n, i in number_attr_list if self.name == n]
        self.number_attr, self.type = (self.number_attr[0].name, 'n_attr') if len(self.number_attr) else (None, self.type)

        self.default = bool(len(self.attr.default_value.ListFields())) and not self.islist and self.type not in ['shape', 'tensor']

    def declaration(self):

        # Basic T types attributes are not used
        if self.name == 'T': return []

        # Number attributes are infered from others (no need for an argument)
        if self.number_attr is not None: return []

        # Convert from TF types
        luatype = {
            'func'  : 'tfe.TFEOp',
            'shape' : 'number[]',
            'int'   : 'number',
            'float' : 'number',
            'string': 'string',
            'type'  : 'number|string',
            'bool'  : 'boolean',
            'tensor': 'tfl.Tensor'
        }[self.type]
        ctype = {
            'func'  : '',
            'shape' : 'int64_t[]',
            'int'   : 'int64_t',
            'float' : 'float',
            'string': '',
            'type'  : 'TF_DataType',
            'bool'  : '',
            'tensor': ''
        }[self.type]

        # Warp list attributes
        if self.islist:
            luatype = luatype.replace('|', '[]|') + '[]'
            if len(ctype):
                ctype = ctype + '[]'

        # Get the default value for the attribute
        # Not yet supported for lists
        # Not supported for tensors or shape
        if self.default and not self.islist and self.type not in ['shape', 'tensor', 'func']:   
            luadefault = {
                'int'    : str(self.attr.default_value.i),
                'bool'   : str(self.attr.default_value.b).lower(),
                'string' : '"' + str(self.attr.default_value.s)[2:-1] + '"',
                'float'  : '{:.4e}'.format(self.attr.default_value.f).replace('inf', 'float_infinity'),
                'type'   : '{}'.format(self.attr.default_value.type)
            }[self.type]
            luadefault_doc = {
                'int'    : str(self.attr.default_value.i),
                'bool'   : str(self.attr.default_value.b).lower(),
                'string' : '"' + str(self.attr.default_value.s)[2:-1] + '"',
                'float'  : '{:.4e}'.format(self.attr.default_value.f).replace('inf', 'float_infinity'),
                'type'   : '"{}"'.format(data_type_name[self.attr.default_value.type].lower())
            }[self.type]
        else:
            luadefault = ''
            luadefault_doc = ''

        # datatype name=defaultval
        return [self.var_name, ctype, luatype, luadefault, luadefault_doc]

    def code(self):

        # Basic T types attributes are not used
        if self.name == 'T': return ''

        if self.islist:
            return textwrap.dedent({
                'func'   : 'op:setAttrFunctionList("{orig:}", {0});',
                'string' : 'op:setAttrStringList("{orig:}", {0});',
                'int'    : 'op:setAttrIntList("{orig:}", {0});',
                'float'  : 'op:setAttrFloatList("{orig:}", {0});',
                'bool'   : 'op:setAttrBoolList("{orig:}", {0});',
                'type'   : 'op:setAttrTypeList("{orig:}", {0});',
                'shape'  : 'op:setAttrShapeList("{orig:}", {0});',
            }[self.type].format(self.var_name, orig=self.name)).replace('\n', '\n\t')
        else:
            return textwrap.dedent({
                'func'  : 'op:setAttrFunction("{orig:}", {0});',
                'shape' : 'op:setAttrShape("{orig:}", {0});',
                'int'   : 'op:setAttrInt("{orig:}", {0});',
                'float' : 'op:setAttrFloat("{orig:}", {0});',
                'string': 'op:setAttrString("{orig:}", {0});',
                'type'  : 'op:setAttrType("{orig:}", {0});', 
                'bool'  : 'op:setAttrBool("{orig:}", {0});',
                'tensor': 'op:setAttrTensor("{orig:}", {0}._tensor or {0});',
                'n_attr': 'op:setAttrInt("{orig:}", #{n_attr:});'
            }[self.type].format(self.var_name, orig=self.name, n_attr=self.number_attr)).replace('\n', '\n\t')    


class Operation:
    def __init__(self, op, tf_doc=None):
        self.op = op
        # self.tf_doc = tf_doc
        self.tf_doc_main = ''
        self.tf_doc_arg = {}
        self.tf_doc_ret = ''
        if tf_doc:
            self.tf_doc_main, self.tf_doc_arg, self.tf_doc_ret = parse_tf_doc(tf_doc)

        # More than one output?
        # if len(self.op.output_arg) > 1:
        #     print(len(self.op.output_arg))
        #     print(self.op.output_arg)
        #     raise Exception("More than one or no output not yet supported: " + self.op.name)

        self.inputs = [inp for inp in op.input_arg]

        # Number attributes define the length of an input list
        number_attr = [(i.number_attr, i) for i in self.inputs if len(i.number_attr) > 0]

        # Attributes
        self.attr_list = sorted([Attribute(a, number_attr) for a in self.op.attr], key=lambda a: a.default)


    def code(self):

        # C++ function body
        template = textwrap.dedent('''
        {}
        {}
        function M.{}({}{})
        \t{}
        \tlocal op = get_context():newOp("{}")
        \t{}
        \t{}
        \treturn parse_execute_results(op:execute())
        end
        ''')

        # Add single input template
        add_inputs = textwrap.dedent('op:addInput({0}._handle or {0})')
        add_inputs_list = textwrap.dedent('op:addInputList(pack_tfe_handle({0}))')

        # Return type of the function
        # out = 'tensor' if len(self.op.output_arg) else 'void'
        num_output = len(self.op.output_arg)
        if num_output == 1:
            out = '---@return tfl.Tensor'
        elif num_output > 1:
            out = '---@return tfl.Tensor[]'
        else:
            out = '---@return nil'

        # snake_case name of the operation
        if self.op.name == self.op.name.upper():
            # all upper
            snk = self.op.name.lower()
        else:
            # avoid conv2_d
            name = self.op.name.replace('Conv2D', 'Conv2d')
            name = name.replace('Conv3D', 'Conv3d')
            name = name.replace('Dilation2D', 'Dilation2d')
            name = name.replace('TPU', 'Tpu')
            name = name.replace('TopK', 'Topk')
            name = name.replace('LMDB', 'Lmdb')
            name = name.replace('LRN', 'Lrn')
            name = name.replace('Pool3D', 'Pool3d')
            name = name.replace('IFFT2D', 'Ifft2d')
            name = name.replace('IFFT3D', 'Ifft3d')
            name = name.replace('IFFT', 'Ifft')
            name = name.replace('FFT2D', 'Fft2d')
            name = name.replace('FFT3D', 'Fft3d')
            name = name.replace('FFT', 'Fft')
            name = name.replace('LSTM', 'Lstm')
            name = name.replace('BatchToSpaceND', 'BatchToSpaceNd')
            name = name.replace('ApplyAdagradDA', 'ApplyAdagradDa')
            name = re.sub(r'([A-Z])([A-Z]+)$', lambda m: '_'+(m.group(1)+m.group(2)).lower(), name)
            name = re.sub(r'^([A-Z])([A-Z]+)([A-Z][a-z0-9])', lambda m: (m.group(1)+m.group(2)).lower()+m.group(3), name)
            name = re.sub(r'([A-Z])([A-Z]+)([A-Z][a-z0-9])', lambda m: '_'+(m.group(1)+m.group(2)).lower()+m.group(3), name)
            snk = re.sub(r'(?<!^)(?=[A-Z])', '_', name).lower() #.replace('const', 'const_tensor')

        # Required input arguments
        # inp = ', '.join(['const std::vector<tensor>&{}'.format(n.name) if len(n.number_attr) or len(n.type_list_attr) else 
        #          'const tensor& {}'.format(n.name.replace('tensor', 'input_tensor')) for i, n in enumerate(self.inputs)])
        inp = ', '.join(['{}'.format(proc_var_name(n.name)) if len(n.number_attr) or len(n.type_list_attr) else 
                 '{}'.format(proc_var_name(n.name.replace('tensor', 'input_tensor'))) for i, n in enumerate(self.inputs)])
        inp_docs = []
        for i, n in enumerate(self.inputs):
            if len(n.number_attr) or len(n.type_list_attr):
                doc = '---@param {} tfl.Tensor[]'.format(proc_var_name(n.name))
            else:
                doc = '---@param {} tfl.Tensor'.format(proc_var_name(n.name.replace('tensor', 'input_tensor')))
            par_doc = self.tf_doc_arg.get(n.name, None)
            if par_doc:
                doc += ' @' + par_doc
            inp_docs.append(doc)
        inp_doc = '\n'.join(inp_docs)

        # Declaration of attributes
        attr_decl = []
        attr_doc = []
        attr_default = []
        for a in self.attr_list:
            dec = a.declaration()
            if len(dec):
                attr_name, ctype, luatype, luadefault, luadefault_doc = tuple(dec)
                attr_decl.append(attr_name)
                doc = '---@param {} {} @'.format(attr_name, luatype)
                if len(luadefault_doc):
                    doc += '(optional {})'.format(luadefault_doc)
                    attr_default.append('{} = {} or {}'.format(attr_name, attr_name, luadefault))
                if len(ctype):
                    doc += '({})'.format(ctype)
                par_doc = self.tf_doc_arg.get(a.name, None)
                if par_doc:
                    doc += ' ' + par_doc
                attr_doc.append(doc)

        atr = ', '.join(attr_decl)
        atr = (', ' + atr) if inp != '' and atr != '' else atr
        attr_doc = '\n'.join(attr_doc)
        attr_default = '\n\t'.join(attr_default)

        # Operation original name
        opn = self.op.name

        # Code for input arguments
        # inp_code = '\n\t'.join(add_inputs_list.format(n.name) if len(n.number_attr) or len(n.type_list_attr) else
        #              add_inputs.format(n.name.replace('tensor', 'input_tensor')) for n in self.inputs)
        inp_codes = []
        for n in self.inputs:
            if len(n.number_attr) or len(n.type_list_attr):
                inp_codes.append(add_inputs_list.format(proc_var_name(n.name)))
            else:
                inp_codes.append(add_inputs.format(proc_var_name(n.name.replace('tensor', 'input_tensor'))))
        inp_code = '\n\t'.join(inp_codes)

        # Code for attributes
        atr_code = '\n\t'.join(a.code() for a in self.attr_list if len(a.code()))

        func_doc = inp_doc + '\n' + attr_doc
        func_doc = func_doc.strip()

        if snk in lua_keywords:
            snk += '_'

        if self.tf_doc_main != '':
            func_doc = self.tf_doc_main.strip() + '\n' + func_doc
        if self.tf_doc_ret != '':
            out += ' @ ' + self.tf_doc_ret.strip()

        return template.format(func_doc, out, snk, inp, atr, attr_default, opn, inp_code, atr_code)


ops_file = textwrap.dedent('''
--- TensorFlow raw_ops mappings
local M = {{}}
local float_infinity = math.huge
local get_context = require('tfl.context').get_context
local TFLTensor = require('tfl.Tensor')
local function pack_tfe_handle(tensors)
    local ret = {{}}
    for i = 1, #tensors do
        ret[i] = tensors[i]._handle or tensors[i]
    end
    return ret
end
local function parse_execute_results(res)
    if #res == 0 then
        return nil
    elseif #res == 1 then
        return require('tfl.Tensor')(res[1])
    else
        local ret = {{}}
        for i = 1, #res do
            ret[i] = require('tfl.Tensor')(res[i])
        end
        return ret
    end
end

--

{}

return M
''')


ops_code = ''
num_ops = 0

# All TF C API operations correspond with tf.raw_ops
for op_name in sorted(dir(tf.raw_ops)):
    if not op_name.startswith("_"):
        num_ops += 1
        #if num_ops == 51:
        #    break
        try:
            tf_func_doc = None
            tf_func = getattr(tf.raw_ops, op_name, None)
            if tf_func:
                tf_func_doc = getattr(tf_func, '__doc__', None)
            # Grab operation definition
            op = [op for op in ops.op if op.name == op_name]
            if len(op) == 0: raise Exception("Operation not found")
            
            op = Operation(op[0], tf_func_doc)
            ops_code += op.code()

            # Everything was ok!
            # print('{:<50}  [{}]'.format(op_name, colored('  Ok  ', 'green')))
        except Exception as err:
            print('{:<50}  [{}]'.format(op_name, colored('Failed', 'red')))
            print('    ', err)
            raise err

with open('raw_ops.lua', 'w') as f:
    f.write(ops_file.format(ops_code))
