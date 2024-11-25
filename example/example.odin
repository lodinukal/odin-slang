package slang_sandbox

import "core:os"
import "core:fmt"
import "core:slice"
import "core:strings"
import sp "../slang"

is_ok :: #force_inline proc (#any_int result: int) {
	result := cast(sp.Result)result
    if sp.FAILED(result) {
        code     := sp.GET_RESULT_CODE(result)
        facility := sp.GET_RESULT_FACILITY(result)
        estr: string 
        switch sp.Result(result) {
            case: estr = "Unknown error"
            case sp.E_NOT_IMPLEMENTED(): estr = "E_NOT_IMPLEMENTED"
            case sp.E_NO_INTERFACE():    estr = "E_NO_INTERFACE"
            case sp.E_ABORT():           estr = "E_ABORT"
            case sp.E_INVALID_HANDLE():  estr = "E_INVALID_HANDLE"
            case sp.E_INVALID_ARG():     estr = "E_INVALID_ARG"
            case sp.E_OUT_OF_MEMORY():   estr = "E_OUT_OF_MEMORY"
            case sp.E_BUFFER_TOO_SMALL(): estr = "E_BUFFER_TOO_SMALL"
            case sp.E_UNINITIALIZED():   estr = "E_UNINITIALIZED"
            case sp.E_PENDING():         estr = "E_PENDING"
            case sp.E_CANNOT_OPEN():     estr = "E_CANNOT_OPEN"
            case sp.E_NOT_FOUND():       estr = "E_NOT_FOUND"
            case sp.E_INTERNAL_FAIL():   estr = "E_INTERNAL_FAIL"
            case sp.E_NOT_AVAILABLE():   estr = "E_NOT_AVAILABLE"
            case sp.E_TIME_OUT():        estr = "E_TIME_OUT"
        }

        fmt.panicf("Failed with error: %v (%v) Facility: %v", estr, code, facility)
    }

}

diagnose :: #force_inline proc ( diagnostics: ^sp.IBlob ) {
    if diagnostics != nil {
        fmt.panicf("%s", cstring(auto_cast diagnostics->getBufferPointer()))
    }
}

safe_release :: proc( ptr: ^sp.IUnknown ) {
    if ptr != nil {
        ptr->Release()
    }
}

test_slang2 :: proc() {
    using sp;

    code, diagnostics: ^IBlob
    r: Result
    
    global_session: ^IGlobalSession
    is_ok(sp.createGlobalSession(sp.API_VERSION, &global_session))
    
    // target_desc := TargetDesc {
    //     structureSize = size_of(TargetDesc),
    //     format  = .METAL,
    //     profile = global_session->findProfile("sm_6_5"),
    // }

    // session_desc := SessionDesc {
    //     structureSize = size_of(SessionDesc),
    //     targets     = &target_desc,
    //     targetCount = 1,
    // }

    // session: ^ISession
    // is_ok(global_session->createSession(session_desc, &session))
    // defer safe_release(session)

    compiler := sp.CreateCompileRequest(auto_cast global_session)
    target_index := sp.AddCodeGenTarget(compiler, .METAL)

    sp.SetDiagnosticCallback(compiler, proc "c" (message: cstring, userData: rawptr){
        context = runtime.default_context()
        fmt.eprintfln("%v", message)
    }, nil)
    
    sp.SetTargetProfile(compiler, 0, global_session->findProfile("sm_6_5"))
    
    tu_idx := sp.AddTranslationUnit(compiler, .SLANG, "main")
    assert(tu_idx == 0)

    sp.AddTranslationUnitSourceFile(compiler, tu_idx, "/Users/harito/projects/games/rockcore-odin/.sandbox/v.slang")
    // sp.SetCompileFlags(compiler, .NO_MANGLING)
    // sp.SetDebugInfoFormat(compiler, .DEFAULT)
    // sp.SetDebugInfoLevel(compiler, .MAXIMAL)
    // sp.SetOptimizationLevel(compiler, .NONE)
    sp.SetOptimizationLevel(compiler, .HIGH)
    sp.SetTargetMatrixLayoutMode(compiler, 0, .ROW_MAJOR)
    
    // vs_idx := sp.AddEntryPoint(compiler, 0, "vs_main", .VERTEX)
    r = sp.Compile(compiler)
    is_ok(r)


    program: ^IComponentType
    r = sp.CompileRequest_getProgramWithEntryPoints(compiler, &program)
    is_ok(r)

    r = program->getEntryPointCode(0, 0, &code, &diagnostics)
    diagnose(diagnostics)
    is_ok(r)

    source_code := transmute(string)slice.bytes_from_ptr(code->getBufferPointer(), auto_cast code->getBufferSize())
    fmt.printfln("%s", source_code)

    // mod: ^IModule
    layout := cast(^Reflection)program->getLayout(0, &diagnostics)
    diagnose(diagnostics)
    assert(layout != nil)

    entry_points := sp.Reflection_getEntryPointCount(layout)
    assert(entry_points == 1)

    dump_inputs(layout)
}

dump_inputs :: proc( layout: ^sp.Reflection ) {
    using sp

    r: Result

    ep_ref := sp.Reflection_getEntryPointByIndex(layout, 0)
    n_params := sp.ReflectionEntryPoint_getParameterCount(ep_ref)

    fmt.printfln("Input params: %v", n_params)
    input := sp.ReflectionEntryPoint_getParameterByIndex(ep_ref, 0)
    type := sp.ReflectionVariableLayout_GetTypeLayout(input)

    n_fields := sp.ReflectionTypeLayout_GetFieldCount(type)
    fmt.printfln("Input fields: %v", n_fields)
    
    for i in 0..<n_fields {

        fields := sp.ReflectionTypeLayout_GetFieldCount(type)
        field  := sp.ReflectionTypeLayout_GetFieldByIndex(type, i)
        
        semantic       := sp.ReflectionVariableLayout_GetSemanticName(field)
        semantic_index := sp.ReflectionVariableLayout_GetSemanticIndex(field)
    
        fvar  := sp.ReflectionVariableLayout_GetVariable(field)
        ftype := sp.ReflectionVariable_GetType(fvar)
    
        full_name_blob: ^IBlob
        r = sp.ReflectionType_GetFullName(ftype, &full_name_blob)
        is_ok(r)
    
        
        full_name := transmute(string)slice.bytes_from_ptr(full_name_blob->getBufferPointer(), auto_cast full_name_blob->getBufferSize())
        fmt.printfln("[%v] %v %v : %v%v", i, full_name, sp.ReflectionVariable_GetName(fvar), semantic, semantic_index)
    }
}

test_slang :: proc() {
    using sp;

    code, diagnostics: ^IBlob
    r: Result
    
    global_session: ^IGlobalSession
    is_ok(sp.slang_createGlobalSession(sp.API_VERSION, &global_session))
    // SLANG_COMPILE_FLAG_NO_MANGLING
    target_desc := TargetDesc {
        structureSize = size_of(TargetDesc),
        format  = .METAL,
        profile = global_session->findProfile("sm_6_5"),
    }

    session_desc := SessionDesc {
        structureSize = size_of(SessionDesc),
        targets     = &target_desc,
        targetCount = 1,
    }

    session: ^ISession
    is_ok(global_session->createSession(session_desc, &session))
    defer safe_release(session)

    fmt.printfln("Loading module...")
    module: ^IModule = session->loadModule("/Users/harito/projects/games/rockcore-odin/.sandbox/v", &diagnostics);
    defer safe_release(module)
    diagnose(diagnostics);

    entry_point_count := module->getDefinedEntryPointCount()
    fmt.printfln("Entry points: %v", entry_point_count)
    if entry_point_count != 1 {
        fmt.eprintfln("Expected a single entry point!")
        os.exit(-1)
    }

    // for i in 0..< entry_point_count {
    //     entry_point: ^IEntryPoint
    //     is_ok(module->getDefinedEntryPoint(0, &entry_point))
    //     defer safe_release(entry_point)
    // }

    entry_point: ^IEntryPoint
    is_ok(module->getDefinedEntryPoint(0, &entry_point))

    fmt.printfln("Linking...")
    components := []^IComponentType {
        module,
        entry_point,
    }

    linked_program: ^IComponentType
    r = session->createCompositeComponentType(
        raw_data(components),
        auto_cast len(components),
        &linked_program,
        &diagnostics
    )
    diagnose(diagnostics)
    is_ok(r)

    target_code: ^IBlob
    r = linked_program->getTargetCode(0, &target_code, &diagnostics)
    diagnose(diagnostics)
    is_ok(r)

    code_size   := target_code->getBufferSize()
    source_code := transmute(string)slice.bytes_from_ptr(target_code->getBufferPointer(), auto_cast code_size)
    fmt.printfln("Compiled Metal Code:")
    fmt.printfln("%s", source_code)

    layout := cast(^Reflection)linked_program->getLayout(0, &diagnostics)
    diagnose(diagnostics)
    assert(layout != nil)

    ep_ref := sp.Reflection_getEntryPointByIndex(layout, 0)
    n_params := sp.ReflectionEntryPoint_getParameterCount(ep_ref)

    fmt.printfln("Input params: %v", n_params)
    input := sp.ReflectionEntryPoint_getParameterByIndex(ep_ref, 0)
    type := sp.ReflectionVariableLayout_GetTypeLayout(input)

    n_fields := sp.ReflectionTypeLayout_GetFieldCount(type)
    fmt.printfln("Input fields: %v", n_fields)
    
    for i in 0..<n_fields {

        fields := sp.ReflectionTypeLayout_GetFieldCount(type)
        field  := sp.ReflectionTypeLayout_GetFieldByIndex(type, i)
        
        semantic       := sp.ReflectionVariableLayout_GetSemanticName(field)
        semantic_index := sp.ReflectionVariableLayout_GetSemanticIndex(field)
    
        fvar  := sp.ReflectionVariableLayout_GetVariable(field)
        ftype := sp.ReflectionVariable_GetType(fvar)
    
        full_name_blob: ^IBlob
        r = sp.ReflectionType_GetFullName(ftype, &full_name_blob)
        is_ok(r)
    
        
        full_name := transmute(string)slice.bytes_from_ptr(full_name_blob->getBufferPointer(), auto_cast full_name_blob->getBufferSize())
        fmt.printfln("[%v] %v %v : %v%v", i, full_name, sp.ReflectionVariable_GetName(fvar), semantic, semantic_index)
    }
}

main :: proc() {
    // test_slang(); if true do return
    test_slang2(); if true do return
}