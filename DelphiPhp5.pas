unit DelphiPhp5;

interface

uses Winapi.Windows, FileExists;

const
  DllPHP				      = 'php5ts.dll';
  SUCCESS				      = 0;
  FAILURE				      = -1;
  IS_NULL				      = 0;
  IS_LONG				      = 1;
  IS_DOUBLE				    = 2;
  IS_BOOL				      = 3;
  IS_ARRAY				    = 4;
  IS_OBJECT				    = 5;
  IS_STRING				    = 6;
  IS_RESOURCE			    = 7;
  IS_CONSTANT			    = 8;
  IS_CONSTANT_AST		  = 9;
  IS_CALLABLE			    = 10;
  ZEND_MODULE_API_NO	= 20090626;
  HASH_UPDATE = 1 SHL 0;
  HASH_ADD = 1 SHL 1;
  HASH_NEXT_INSERT = 1 SHL 2;

  HASH_DEL_KEY = 0;
  HASH_DEL_INDEX = 1;
  HASH_DEL_KEY_QUICK = 2;




type
  PPBucket = ^PBucket;
  PBucket = ^TBucket;
  TBucket = record
    h           : ulong;
    nKeyLength  : uint;
    pData       : pointer;
    pDataPtr    : pointer;
    pListNext   : PBucket;
    pListLast   : PBucket;
    pNext       : PBucket;
    pLast       : PBucket;
    arKey       : array [0 .. 1] of AnsiChar;
  end;

  PHashTable = ^THashTable;
  THashTable = record
    nTableSize          : uint;
    nTableMask          : uint;
    nNumOfElements      : uint;
    nNextFreeElement    : ulong;
    pInternalPointer    : PBucket;
    pListHead           : PBucket;
    pListTail           : PBucket;
    arBuckets           : PPBucket;
    pDestructor         : pointer;
    persistent          : boolean;
    nApplyCount         : byte;
    bApplyProtection    : boolean;
  end;

  p_zend_module_entry = ^_zend_module_entry;
  _zend_module_entry = record
    size                  : word;
    zend_api              : dword;
    zend_debug            : byte;
    zts                   : byte;
    ini_entry             : pointer;
    deps                  : pointer;
    name                  : PAnsiChar;
    functions             : Pointer;
    module_startup_func   : pointer;
    module_shutdown_func  : pointer;
    request_startup_func  : pointer;
    request_shutdown_func : pointer;
    info_func             : pointer;
    version               : PAnsiChar;
    globals_size          : size_t;
    globals_id_ptr        : pointer;
    globals_ctor          : pointer;
    globals_dtor          : pointer;
    post_deactivate_func  : pointer;
    module_started        : integer;
    _type                 : byte;
    handle                : pointer;
    module_number         : Integer;
    build_id              : PAnsiChar;
  end;

  P_zend_arg_info = ^_zend_arg_info;
  _zend_arg_info = record
    name              : PAnsiChar;
    name_len          : uint;
    class_name        : PAnsiChar;
    class_name_len    : uint;
    array_type_hint   : boolean;
    allow_null        : boolean;
    pass_by_reference : boolean;
    return_reference  : boolean;
    required_num_args : integer;
  end;

  PZend_class_entry = ^Tzend_class_entry;

  zend_object_value = record
    handle:Integer;
    handlers:Pointer;
  end;

  _zend_function_entry = record
    fname     : PAnsiChar;
    handler   : pointer;
    arg_info  : P_zend_arg_info;
    num_args  : uint;
    flags     : uint;
  end;

  Pzvalue_value = ^zvalue_value;
  zvalue_value = record
    case integer of
      0: (lval	: Longint;);
      1: (dval	: double;);
      2: (str	: record
					  val	: PAnsiChar;
					  len	: LongInt;
				  end;);
      3: (ht	: PHashTable;);
      4: (obj	: zend_object_value;);
  end;


  pppzval = ^ppzval;
  ppzval = ^pzval;
  pzval = ^zval;
  pzval_array_ex = array of pzval;

  zval = record
    value         : zvalue_value;
    refcount__gc  : uint;
    _type         : Byte;
    is_ref__gc    : Byte;
  end;


  Tzend_class_entry = record
   _type : AnsiChar;
   name  : PAnsiChar;
   name_length : uint;
   parent : PZend_class_entry;
   refcount : integer;
   constants_updated : Boolean;
   ce_flags : uint;

   function_table : THashTable;
   default_properties : THashTable;
   properties_info : THashTable;
   default_static_members : THashTable;

   static_members : PHashTable;
   constants_table : THashTable;
   builtin_functions : pointer;

   _constructor : pointer;
   _destructor :  pointer;
   clone : pointer;
   __get : pointer;
   __set : pointer;
   //{$IFDEF PHP510}
   __unset : pointer;
   __isset : pointer;
   //{$ENDIF}
   __call: pointer;
   //{$IFDEF PHP530}
   __callstatic : pointer;
   //{$ENDIF}
   //{$IFDEF PHP520}
   __tostring : pointer;
   //{$ENDIF}
   //{$IFDEF PHP510}
   serialize_func : pointer;
   unserialize_func : pointer;
  // {$ENDIF}
   iterator_funcs : pointer;

   create_object : pointer;
   get_iterator : pointer;
   interface_gets_implemented : pointer;

   get_static_method : pointer;

   serialize : pointer;
   unserialize : pointer;

   interfaces : pointer;
   num_interfaces : uint;

   filename : PAnsiChar;
   line_start : uint;
   line_end : uint;
   doc_comment : PAnsiChar;
   doc_comment_len : uint;

   module : pointer;
  end;

  PZendObject = ^TZendObject;
  _zend_object = record
    gc: pointer;
    handle: uint32;
    ce: Pzend_class_entry;
    handlers: pointer;
    properties: PHashTable;
    properties_table: array[0..0] of zval;
  end;
  zend_object = _zend_object;
  TZendObject = _zend_object;








 Pzend_executor_globals = ^zend_executor_globals;
  zend_executor_globals  = record
    return_value_ptr_ptr : ppzval;

     uninitialized_zval : zval;
     uninitialized_zval_ptr : pzval;

     error_zval : zval;
     error_zval_ptr : pzval;

     function_state_ptr : pointer;
     arg_types_stack : pointer;

     // symbol table cache
     symtable_cache : array[0..31] of PHashTable;
     symtable_cache_limit : ^PHashTable;
     symtable_cache_ptr : ^PHashTable;

     opline_ptr : pointer;

     active_symbol_table : PHashTable;
     symbol_table : THashTable;	// main symbol table

     included_files : THashTable;	// files already included */


     bailout : pointer;

     error_reporting : integer;
     orig_error_reporting : integer;
     exit_status : integer;

     active_op_array : pointer;

     function_table : PHashTable;	// function symbol table */
     class_table : PHashTable;  	// class table
     zend_constants : PHashTable;	// constants table */

     scope : pointer;
     _this : pzval;

     precision : longint;

     ticks_count : integer;

     in_execution : Boolean;
     {$IFDEF PHP5}
     in_autoload : PHashTable;
     {$IFDEF PHP510}
     autoload_func : pointer;
     {$ENDIF}
     {$ENDIF}

     {$IFDEF PHP4}
     bailout_set : zend_bool;
     {$ENDIF}

     full_tables_cleanup : Boolean;
     {$IFDEF PHP5}
     ze1_compatibility_mode : zend_bool;
     {$ENDIF}

     // for extended information support */
     no_extensions : Boolean;

     timed_out : Boolean;

     regular_list : THashTable;
     persistent_list : ThashTable;

     argument_stack : Pointer;

     free_op1, free_op2 : pzval;
     unary_op : pointer;
     binary_op : pointer;

     garbage : array[0..1] of pzval;
     garbage_ptr : integer;


      user_error_handler_error_reporting : integer;
     user_error_handler : pzval;
     user_exception_handler : pzval;
     user_error_handlers_error_reporting : Pointer;

     user_error_handlers : Pointer;
     user_exception_handlers : Pointer;


	//* timeout support */
     timeout_seconds : integer;
     lambda_count : integer;
     ini_directives : PHashTable;

      objects_store : Pointer;
      exception : pzval;
      opline_before_exception : pointer;
      current_execute_data : pointer;

      current_module : pointer;

      std_property_info : Pointer;

     //* locale stuff */

     {$IFNDEF PHP510}
     float_separator : AnsiChar;
     {$ENDIF}

     reserved: array[0..3] of pointer;
   end;






var
  PHP5dll				        : THandle = 0;
  ZEND_MODULE_BUILD_ID	: PAnsiChar = 'API20090626,TS,VC9';

  zend_get_parameters_ex : function(param_count : Integer; Args : ppzval) :integer; cdecl varargs;
  _estrndup : function(s : PAnsiChar; Len : Cardinal; zend_filename : PAnsiChar;
                        zend_lineno : uint; zend_orig_filename : PAnsiChar;
                                    zend_orig_line_no : uint) : PAnsiChar; cdecl;
  zend_wrong_param_count : procedure(TSRMLS_D : pointer); cdecl;

    zend_hash_func:function(arKey: PAnsiChar; nKeyLength: uint): Longint; cdecl;
  _zend_hash_quick_add_or_update:function(ht: PHashTable; arKey: PAnsiChar; nKeyLength: uint; h: uint; out pData: pzval; nDataSize: uint; pDest: PPointer; flag: Integer) : Integer; cdecl;
  zend_hash_exists: function(ht: PHashTable; arKey: PAnsiChar; nKeyLength: uint): Integer; cdecl;
  zend_hash_index_exists: function(ht: PHashTable; h: ulong): Integer; cdecl;
  zend_hash_del_key_or_index: function(ht: PHashTable; arKey: PAnsiChar; nKeyLength: uint; y: ulong; flag: Integer): Integer; cdecl;
  zend_hash_quick_find: function(const ht: PHashTable; arKey: PAnsiChar; nKeyLength: uint; h: ulong; out pData: ppzval): Integer; cdecl;
  _emalloc: function(size: size_t; __zend_filename: PAnsiChar; __zend_lineno: uint; __zend_orig_filename: PAnsiChar; __zend_orig_line_no: uint): Pointer; cdecl;

  zend_eval_string : function(str: PAnsiChar; val: pointer; strname: PAnsiChar; tsrm: pointer): integer; cdecl;

    ts_resource_ex : function(id: integer; p: pointer): pointer; cdecl;

    call_user_function : function(function_table: PHashTable; object_pp: pzval;
                         function_name: pzval; return_ptr: pzval; param_count: uint; params: pzval_array_ex;
                          TSRMLS_DC: Pointer): integer; cdecl;



   _zval_dtor_func : procedure(val: pzval; __zend_filename: PAnsiChar; __zend_lineno: uint); cdecl;

 { zend_call_method:function(object_pp:Pzval; obj_ce:pointer; fn_proxy:pointer;
  function_name:PAnsiChar;function_name_len:size_t; retval:PZval; param_count:Integer;
  arg1:PZval; arg2:PZval):pzval; cdecl;
           }



  procedure ZVAL_TRUE(value:pzval);
  procedure ZVAL_FALSE(value:pzval);
  procedure ZvalString(z:pzval) overload;
  procedure ZvalString(z:pzval; s:PAnsiChar; len:Integer = 0) overload;
  procedure ZvalString(z:pzval; s:PWideChar; len:Integer = 0) overload;
  procedure ZvalString(z:pzval; s:string; len:Integer = 0) overload;
  function HRESULTStr(h:HRESULT):Pchar;
  procedure ZvalHRESULTStr(z:pzval; h:HRESULT);
  function estrndup(s: PAnsiChar; len: Cardinal): PAnsiChar;
  function ISPHPLib : boolean;
  function LoadZEND(const DllFilename:AnsiString = DllPHP): boolean;
  procedure UnloadZEND;


  function ZvalInt(z:zval):Integer;
  function ZvalDouble(z:zval):Double;
  function ZvalBool(z:zval):Boolean;

  function ZvalStrS(z:zval) : string;
  function ZvalStr(z:zval)  : AnsiString;
  function ZvalStrW(z:zval) : WideString;

  procedure ZvalVALStrNull(z: pzval); overload;
  procedure ZvalVAL(z: pzval; s: AnsiString; len: Integer = 0); overload;

  procedure ZvalVAL(z:pzval; v:Boolean) overload;
  procedure ZvalVAL(z:pzval; v:Integer; const _type:Integer = IS_LONG) overload;
  procedure ZvalVAL(z:pzval) overload;
  procedure ZvalVAL(z:pzval; v:Double) overload;
  procedure ZvalVAL(z: pzval; v: Extended); overload;


function ZvalArrayAdd(z: pzval; Args: array of const): Integer; overload;
function ZvalArrayAdd(z: pzval; idx: Integer; Args: array of const)
  : Integer; overload;
function ZvalArrayAdd(z: pzval; key: AnsiString; Args: array of const)
  : Integer; overload;

function ZValArrayKeyExists(v: pzval; key: AnsiString): Boolean; overload;
function ZValArrayKeyExists(v: pzval; key: AnsiString; out pData: pzval)
  : Boolean; overload;
function ZValArrayKeyExists(v: pzval; idx: Integer): Boolean; overload;
function ZValArrayKeyExists(v: pzval; idx: Integer; out pData: pzval)
  : Boolean; overload;
function ZValArrayKeyDel(v: pzval; key: AnsiString): Boolean; overload;
function ZValArrayKeyDel(v: pzval; idx: Integer): Boolean; overload;

function ZValArrayKeyFind(v: pzval; key: AnsiString; out pData: ppzval)
  : Boolean; overload;
function ZValArrayKeyFind(v: pzval; idx: Integer; out pData: ppzval)
  : Boolean; overload;

 function GetArgPZval(Args: TVarRec; const _type: Integer = IS_LONG;
  Make: Boolean = false): pzval;

 procedure ALLOC_ZVAL(out Result: pzval);
procedure INIT_PZVAL(p: pzval);
procedure MAKE_STD_ZVAL(out Result: pzval);

  function emalloc(size: size_t): pointer;
  function GetExecutorGlobals : pzend_executor_globals;
    procedure _zval_dtor(val: pzval; __zend_filename: PAnsiChar; __zend_lineno: uint);
implementation

function ISPHPLib : boolean;
begin
  Result := PHP5dll <> 0;
end;


function LoadZEND;
begin
  result := false;
  if FileExists_(string(DllFilename)) then begin
    PHP5dll := LoadLibraryA(PAnsiChar(DllFilename));
    if (PHP5dll <> 0) then begin
      zend_get_parameters_ex := GetProcAddress(PHP5dll, 'zend_get_parameters_ex');
      _estrndup := GetProcAddress(PHP5dll, '_estrndup');

     zend_hash_func := GetProcAddress(PHP5dll, 'zend_hash_func');
     _zend_hash_quick_add_or_update := GetProcAddress(PHP5dll, '_zend_hash_quick_add_or_update');
     zend_hash_exists := GetProcAddress(PHP5dll, 'zend_hash_exists');
    zend_hash_index_exists  := GetProcAddress(PHP5dll, 'zend_hash_index_exists');
     zend_hash_del_key_or_index := GetProcAddress(PHP5dll, 'zend_hash_del_key_or_index');
      zend_hash_quick_find := GetProcAddress(PHP5dll, 'zend_hash_quick_find');
       _emalloc:= GetProcAddress(PHP5dll, '_emalloc');

       zend_eval_string:= GetProcAddress(PHP5dll, 'zend_eval_string');

       ts_resource_ex := GetProcAddress(PHP5dll, 'ts_resource_ex');
        call_user_function := GetProcAddress(PHP5dll, 'call_user_function');
               _zval_dtor_func := GetProcAddress(PHP5dll, '_zval_dtor_func');

      zend_wrong_param_count := GetProcAddress(PHP5dll, 'zend_wrong_param_count');
       //zend_call_method := GetProcAddress(PHP5dll, 'zend_call_method');


      result := true;
    end;
  end;
end;

procedure _zval_dtor(val: pzval; __zend_filename: PAnsiChar; __zend_lineno: uint);
begin
  if val^._type <= IS_BOOL then
   Exit
     else
       _zval_dtor_func(val, __zend_filename, __zend_lineno);
end;

function GetGlobalResource(resource_name: AnsiString) : pointer;
var
 global_id : pointer;
 global_value : integer;
 global_ptr   : pointer;
 tsrmls_dc : pointer;
begin
  Result := nil;
  try
    global_id := GetProcAddress(PHP5dll, PAnsiChar(resource_name));
    if Assigned(global_id) then
     begin
       tsrmls_dc :=  ts_resource_ex(0, nil);
       global_value := integer(global_id^);
       asm
         mov ecx, global_value
         mov edx, dword ptr tsrmls_dc
         mov eax, dword ptr [edx]
         mov ecx, dword ptr [eax+ecx*4-4]
         mov global_ptr, ecx
       end;
       Result := global_ptr;
     end;
  except
    Result := nil;
  end;
end;


function GetExecutorGlobals : pzend_executor_globals;
begin
  result := GetGlobalResource('executor_globals_id');
end;

procedure UnloadZEND;
begin
  if ISPHPLib then
    FreeLibrary(PHP5dll);
end;


function estrndup;
begin
  if assigned(s) then
    Result := _estrndup(s, len, nil, 0, nil, 0)
  else
    Result := nil;
end;


function HRESULTStr(h:HRESULT):Pchar;
begin
  FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER or FORMAT_MESSAGE_FROM_SYSTEM, nil, h,MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),@Result,0,nil);
end;


function ZvalInt;
var
  E: Integer;
begin
  Case z._type of
    IS_LONG:
      Result := z.value.lval;
    IS_DOUBLE:
      Result := Trunc(z.value.dval);
    IS_BOOL:
      Result := Ord(not (z.value.lval = 0));
    IS_STRING:
      Val(z.value.str.val, Result, E);
  else
    Result := 0;
  end;
end;

function valfloat(s: string; var err: integer): extended;
var  i: integer;  x: extended;
begin
  for i:=1 to length(s) do if s[i]=',' then s[i]:='.';
  Val(s, x, err);    valfloat:=x;
end;

function ZvalDouble;
var
  E: Integer;
begin
  Case z._type of
    IS_LONG:
      Result := trunc(z.value.lval);
    IS_DOUBLE:
      Result := z.value.dval;
    IS_BOOL:
      Result := Ord(not (z.value.lval = 0));
    IS_STRING:
      Result := valfloat(z.value.str.val, E);
  else
    Result := 0;
  end;
end;

function ZvalBool;
var
  E: Integer;
begin
  Case z._type of
    IS_LONG:
      Result := not (z.value.lval = 0);
    IS_DOUBLE:
      Result := not (z.value.dval < 1);
    IS_BOOL:
      Result := not (z.value.lval = 0);
    IS_STRING:
      Result := not (z.value.str.len = 0);
  else
    Result := false;
  end;
end;

function ZvalStrS;
begin
 Result := z.value.str.val;
end;

function ZvalStr;
begin
 Result := z.value.str.val;
end;

function ZvalStrW;
begin
 Result := WideString(z.value.str.val);
end;


procedure ZvalVAL(z: pzval; v: Boolean);
Begin
  z._type := IS_BOOL;
  z.value.lval := Integer(v);
End;

procedure ZvalVAL(z: pzval; v: Integer; const _type: Integer = IS_LONG);
Begin
  z._type := _type;
  z.value.lval := v;
End;

procedure ZvalVAL(z: pzval);
Begin
  z._type := IS_NULL;
End;

procedure ZvalVAL(z: pzval; v: Double);
Begin
  z._type := IS_DOUBLE;
  z.value.dval := v;
End;

procedure ZvalVAL(z: pzval; v: Extended);
var
  D: Double;
Begin
  D := v;
  z._type := IS_DOUBLE;
  z.value.dval := D;
End;

procedure ZvalVALStrNull(z: pzval);
begin
  z^.value.str.len := 0;
  z^.value.str.val := '';
  z^._type := IS_STRING;
end;

procedure ZvalVAL(z: pzval; s: AnsiString; len: Integer = 0);
var
  lens: Integer;
  AChar: PAnsiChar;
begin
  AChar := PAnsiChar(s);

  if not assigned(AChar) then
    ZvalVALStrNull(z)
  else
  begin
    if len = 0 then
      lens := Length(AChar)
    else
      lens := len;

    z^.value.str.len := lens;
    z^.value.str.val := _estrndup(AChar, lens, nil, 0, nil, 0);
    z^._type := IS_STRING;
  end;
end;


procedure ZVAL_TRUE;
begin
  value^._type := IS_BOOL;
  value^.value.lval := 1;
end;

procedure ZVAL_FALSE;
begin
  value^._type := IS_BOOL;
  value^.value.lval := 0;
end;

procedure ZvalString(z:pzval);
begin
  z^.value.str.len := 0;
  z^.value.str.val := '';
  z^._type := IS_STRING;
end;

procedure ZvalString(z:pzval; s:PAnsiChar; len:Integer = 0);
var
  lens:Integer;
begin
  if not assigned(s) then
    ZvalString(z)
  else begin
    if len = 0 then
      lens := Length(s)
    else
      lens := len;

    z^.value.str.len := lens;
    z^.value.str.val := estrndup(s, lens);
    z^._type := IS_STRING;
  end;
end;

procedure ZvalString(z:pzval; s:PWideChar; len:Integer = 0);
begin
  if not assigned(s) then
    ZvalString(z)
  else
    ZvalString(z, PAnsiChar(AnsiString(WideString(s))), len);
end;

procedure ZvalString(z:pzval; s:string; len:Integer = 0);
var
  _s:PWideChar;
begin
  _s := PWideChar(s);

  if not assigned(_s) then
    ZvalString(z)
  else
    ZvalString(z, _s, len);
end;

procedure ZvalHRESULTStr(z:pzval; h:HRESULT);
begin
  ZvalString(z, HRESULTStr(h));
end;

function emalloc(size: size_t): pointer;
begin
  Result := _emalloc(size, nil, 0, nil, 0);
end;

procedure ALLOC_ZVAL(out Result: pzval);
begin
  Result := emalloc(sizeof(zval));
end;

procedure INIT_PZVAL(p: pzval);
begin
  p^.refcount__gc := 1;
  p^.is_ref__gc := 0;
end;

procedure MAKE_STD_ZVAL(out Result: pzval);
begin
  ALLOC_ZVAL(Result);
  INIT_PZVAL(Result);
end;



function GetArgPZval;
begin
  if Args._Reserved1 = 0 then // nil
  begin
    if Make then
      MAKE_STD_ZVAL(Result);
    Result._type := IS_NULL;
  end
  else if Args.VType = vtPointer then
    Result := Args.VPointer
  else
  begin
    if Make then
      MAKE_STD_ZVAL(Result);
    case Args.VType of
      vtInteger:
        ZvalVAL(Result, Args.VInteger, _type);
      vtInt64:
        ZvalVAL(Result, NativeInt(Args.VInt64^), _type);
      vtBoolean:
        ZvalVAL(Result, Args.VBoolean);
      vtExtended:
        ZvalVAL(Result, Args.VExtended^);
      vtClass, vtObject:
        ZvalVAL(Result, Args._Reserved1);
      vtString:
        ZvalVAL(Result, AnsiString(Args.VString^));
      vtAnsiString:
        ZvalVAL(Result, PAnsiChar(Args.VAnsiString));
      vtUnicodeString:
        ZvalVAL(Result, UnicodeString(Args._Reserved1));
      vtWideChar:
        ZvalVAL(Result, AnsiString(Args.VWideChar));
      vtChar:
        ZvalVAL(Result, Args.VChar);
      vtPWideChar:
        ZvalVAL(Result, Args.VPWideChar);
      vtPChar:
        ZvalVAL(Result, Args.VPChar);
      vtWideString:
        ZvalVAL(Result, PWideChar(Args.VWideString));
    end;
  end;
end;







function AddElementZvalArray(z: pzval; Args: array of const; flag: Integer;
  idx: uint = 0; len: uint = 0; const key: AnsiString = ''): Integer;
var
  tmp: pzval;
  arKey: PAnsiChar;
begin
  Result := FAILURE;
  if z._type <> IS_ARRAY then
    exit;

  if len <> 0 then
  begin
    inc(len);
    arKey := PAnsiChar(key);
    idx := zend_hash_func(arKey, len);
  end;

  tmp := GetArgPZval(Args[0], 1, true);
  Result := _zend_hash_quick_add_or_update(z.value.ht, arKey, len, idx, tmp,
    sizeof(pzval), nil, flag);
end;

// Add Next
function ZvalArrayAdd(z: pzval; Args: array of const): Integer; overload;
begin
  Result := FAILURE;
  if z._type <> IS_ARRAY then
    exit;
  Result := AddElementZvalArray(z, Args, HASH_NEXT_INSERT,
    z.value.ht.nNextFreeElement);
end;

// Add Index
function ZvalArrayAdd(z: pzval; idx: Integer; Args: array of const)
  : Integer; overload;
begin
  Result := AddElementZvalArray(z, Args, HASH_UPDATE, idx);
end;

// Add Assoc
function ZvalArrayAdd(z: pzval; key: AnsiString; Args: array of const)
  : Integer; overload;
begin
  Result := AddElementZvalArray(z, Args, HASH_UPDATE, 0, Length(key), key);
end;

function IsArrayRetVal(v: pzval): Boolean;
begin
  Result := v._type = IS_ARRAY;
end;

function ZValArrayKeyExists(v: pzval; key: AnsiString): Boolean; overload;
begin
  Result := false;
  if v._type <> IS_ARRAY then
    exit;
     
  if v.value.ht.nNumOfElements = 0  then
    exit;
    
  Result := zend_hash_exists(v.value.ht, PAnsiChar(key), Length(key) + 1) = 1;
end;

function ZValArrayKeyExists(v: pzval; idx: Integer): Boolean; overload;
begin
  Result := false;
  if (v._type <> IS_ARRAY) then
    exit;
    
  if v.value.ht.nNumOfElements = 0  then
    exit;
  
  Result := zend_hash_index_exists(v.value.ht, idx) = 1;
end;

function ZValArrayKeyExists(v: pzval; key: AnsiString; out pData: pzval)
  : Boolean; overload;
var
  tmp: ppzval;
begin
  Result := ZValArrayKeyExists(v, key);
  if Result then
  begin
    pData := nil;
    if ZValArrayKeyFind(v, key, tmp) then
      pData := tmp^;
  end;
end;

function ZValArrayKeyExists(v: pzval; idx: Integer; out pData: pzval)
  : Boolean; overload;
var
  tmp: ppzval;
begin
  Result := ZValArrayKeyExists(v, idx);
  if Result then
  begin
    pData := nil;
    if ZValArrayKeyFind(v, idx, tmp) then
      pData := tmp^;
  end;
end;

function ZValArrayKeyDel(v: pzval; key: AnsiString): Boolean; overload;
begin
  Result := false;
  if ZValArrayKeyExists(v, key) then
    Result := zend_hash_del_key_or_index(v.value.ht, PAnsiChar(key),
      Length(key) + 1, 0, HASH_DEL_KEY) = SUCCESS;
end;

function ZValArrayKeyDel(v: pzval; idx: Integer): Boolean; overload;
begin
  Result := false;
  if ZValArrayKeyExists(v, idx) then
    Result := zend_hash_del_key_or_index(v.value.ht, nil, 0, idx,
      HASH_DEL_INDEX) = SUCCESS;
end;

function ZValArrayKeyFind(v: pzval; key: AnsiString; out pData: ppzval)
  : Boolean; overload;
var
  keyStr: PAnsiChar;
  KeyLength: uint;
begin
  keyStr := PAnsiChar(key);
  KeyLength := Length(key) + 1;

  Result := zend_hash_quick_find(v.value.ht, keyStr, KeyLength,
    zend_hash_func(keyStr, KeyLength), pData) = SUCCESS;
end;

function ZValArrayKeyFind(v: pzval; idx: Integer; out pData: ppzval)
  : Boolean; overload;
begin
  Result := zend_hash_quick_find(v.value.ht, nil, 0, idx, pData) = SUCCESS;
end;






end.
