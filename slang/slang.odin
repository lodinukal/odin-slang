package slang

import "core:c"
import win32 "core:sys/windows" // TODO(Dragos): use something cross platform. maybe a "core:sys/com" would be useful
import "vendor:directx/dxgi"

foreign import libslang "lib/slang.lib"

// Note(Dragos): This is defined to be "pointer size". So ummmm check later
Int :: int
UInt :: uint
Bool :: bool
Result :: i32

API_VERSION :: 0

IUnknown_UUID := dxgi.IID{0x00000000, 0x0000, 0x0000, {0xC0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x46}}


PassThrough :: enum i32 {
	None,
	FXC,
	DXC,
	GLSLANG,
	SPIRV_DIS,
	CLANG,
	VISUAL_STUDIO,
	GCC,
	GENERIC_C_CPP,
	NVRTC,
	LLVM,
	SPIRV_OPT,
	METAL,
	TINT,
}


CompileTarget :: enum i32 {
	UNKNOWN,
	None,
	GLSL,
	GLSL_VULKAN_DEPRECATED,
	GLSL_VULKAN_ONE_DESC_DEPRECATED,
	HLSL,
	SPIRV,
	SPIRV_ASM,
	DXBC,
	DXBC_ASM,
	DXIL,
	DXIL_ASM,
	C_SOURCE,
	CPP_SOURCE,
	HOST_EXECUTABLE,
	SHADER_SHARED_LIBRARY,
	SHADER_HOST_CALLABLE,
	CUDA_SOURCE,
	PTX,
	CUDA_OBJECT_CODE,
	OBJECT_CODE,
	HOST_CPP_SOURCE,
	HOST_HOST_CALLABLE,
	CPP_PYTORCH_BINDINGS,
	METAL,
	METAL_LIB,
	METAL_LIB_ASM,
	HOST_SHARED_LIBRARY,
	WGSL,
	WGSL_SPIRV_ASM,
	WGSL_SPIRGV,
}

ContainerFormat :: enum i32 {
	NONE,
	CONTAINER_FORMAT_SLANG_MODULE,
}

ArchiveType :: enum i32 {
	UNDEFINED,
	ZIP,
	RIFF,
	RIFF_DEFLATE,
	RIFF_LZ4,
}

// TODO(Dragos): check correctness of the generated bitset
// Note(Dragos): the SlangCompileFlags are defined as 1 << n, so declaring things like this makes it slightly incompatible. This needs to be checked in practice
CompileFlag :: enum u32 {
	NO_MANGLING = 3,
	NO_CODEGEN = 4,
	OBFUSCATE = 5,
	// NO_CHECKING = 0,
	// SPLIT_MIXED_TYPES = 0,
}
CompileFlags :: bit_set[CompileFlag; u32]

TargetFlag :: enum u32 {
	/* [deprecated] */ PARAMETER_BLOCK_USE_REGISTER_SPACE = 4, // This behavior is now enabled unconditionally
	GENERATE_WHOLE_PROGRAM = 8,
	DUMP_IR = 9,
	GENERATE_SPIRV_DIRECTLY = 10,
}
TargetFlags :: bit_set[TargetFlag; u32]

kDefaultTargetFlags :: TargetFlags {
	.GENERATE_SPIRV_DIRECTLY,
}

FloatingPointMode :: enum u32 {
	DEFAULT,
	FAST,
	PRECISE,
}

LineDirectiveMode :: enum u32 {
	DEFAULT,
	NONE,
	STANDARD,
	GLSL,
	SOURCE_MAP,
}

SourceLanguage :: enum i32 {
	Unknown,
	SLANG,
	HLSL,
	GLSL,
	C,
	CPP,
	CUDA,
	SPIRV,
	METAL,
	WGSL,
}

ProfileID :: enum u32 { 
	Unknown,
}

CapabilityID :: enum i32 {
	UNKNOWN,
}

MatrixLayoutMode :: enum u32 {
	UNKNOWN,
	ROW_MAJOR,
	COLUMN_MAJOR,
}

Stage :: enum u32 {
	NONE,
	VERTEX,
	HULL,
	DOMAIN,
	GEOMETRY,
	FRAGMENT,
	COMPUTE,
	RAY_GENERATION,
	INTERSECTION,
	ANY_HIT,
	CLOSEST_HIT,
	MISS,
	CALLABLE,
	MESH,
	AMPLIFICATION,
	PIXEL = FRAGMENT, // alias
}

DebugInfoLevel :: enum u32 {
	NONE,
	MINIMAL,
	STANDARD,
	MAXIMAL,
}

DebugInfoFormat :: enum u32 {
	DEFAULT,
	C7,
	PDB,
	STABS,
	COFF,
	DWARF,
}

OptimizationLevel :: enum u32 {
	NONE,
	DEFAULT,
	HIGH,
	MAXIMAL,
}

// Note(Dragos): the enum integral is not specified here
EmitSpirvMethod :: enum {
	DEFAULT,
	VIA_GLSL,
	DIRECTLY,
}

CompilerOptionName :: enum {
	MacroDefine, // stringValue0: macro name;  stringValue1: macro value
	DepFile,
	EntryPointName,
	Specialize,
	Help,
	HelpStyle,
	Include, // stringValue: additional include path.
	Language,
	MatrixLayoutColumn,         // bool
	MatrixLayoutRow,            // bool
	ZeroInitialize,             // bool
	IgnoreCapabilities,         // bool
	RestrictiveCapabilityCheck, // bool
	ModuleName,                 // stringValue0: module name.
	Output,
	Profile, // intValue0: profile
	Stage,   // intValue0: stage
	Target,  // intValue0: CodeGenTarget
	Version,
	WarningsAsErrors, // stringValue0: "all" or comma separated list of warning codes or names.
	DisableWarnings,  // stringValue0: comma separated list of warning codes or names.
	EnableWarning,    // stringValue0: warning code or name.
	DisableWarning,   // stringValue0: warning code or name.
	DumpWarningDiagnostics,
	InputFilesRemain,
	EmitIr,                        // bool
	ReportDownstreamTime,          // bool
	ReportPerfBenchmark,           // bool
	ReportCheckpointIntermediates, // bool
	SkipSPIRVValidation,           // bool
	SourceEmbedStyle,
	SourceEmbedName,
	SourceEmbedLanguage,
	DisableShortCircuit,            // bool
	MinimumSlangOptimization,       // bool
	DisableNonEssentialValidations, // bool
	DisableSourceMap,               // bool
	UnscopedEnum,                   // bool
	PreserveParameters, // bool: preserve all resource parameters in the output code.
	// Target
	Capability,                // intValue0: CapabilityName
	DefaultImageFormatUnknown, // bool
	DisableDynamicDispatch,    // bool
	DisableSpecialization,     // bool
	FloatingPointMode,         // intValue0: FloatingPointMode
	DebugInformation,          // intValue0: DebugInfoLevel
	LineDirectiveMode,
	Optimization, // intValue0: OptimizationLevel
	Obfuscate,    // bool
	VulkanBindShift, // intValue0 (higher 8 bits): kind; intValue0(lower bits): set; intValue1:
					 // shift
	VulkanBindGlobals,       // intValue0: index; intValue1: set
	VulkanInvertY,           // bool
	VulkanUseDxPositionW,    // bool
	VulkanUseEntryPointName, // bool
	VulkanUseGLLayout,       // bool
	VulkanEmitReflection,    // bool
	GLSLForceScalarLayout,   // bool
	EnableEffectAnnotations, // bool
	EmitSpirvViaGLSL,     // bool (will be deprecated)
	EmitSpirvDirectly,    // bool (will be deprecated)
	SPIRVCoreGrammarJSON, // stringValue0: json path
	IncompleteLibrary,    // bool, when set, will not issue an error when the linked program has
						  // unresolved extern function symbols.
	// Downstream
	CompilerPath,
	DefaultDownstreamCompiler,
	DownstreamArgs, // stringValue0: downstream compiler name. stringValue1: argument list, one
					// per line.
	PassThrough,
	// Repro
	DumpRepro,
	DumpReproOnError,
	ExtractRepro,
	LoadRepro,
	LoadReproDirectory,
	ReproFallbackDirectory,
	// Debugging
	DumpAst,
	DumpIntermediatePrefix,
	DumpIntermediates, // bool
	DumpIr,            // bool
	DumpIrIds,
	PreprocessorOutput,
	OutputIncludes,
	ReproFileSystem,
	SerialIr,    // bool
	SkipCodeGen, // bool
	ValidateIr,  // bool
	VerbosePaths,
	VerifyDebugSerialIr,
	NoCodeGen, // Not used.
	// Experimental
	FileSystem,
	Heterogeneous,
	NoMangle,
	NoHLSLBinding,
	NoHLSLPackConstantBufferElements,
	ValidateUniformity,
	AllowGLSL,
	EnableExperimentalPasses,
	// Internal
	ArchiveType,
	CompileCoreModule,
	Doc,
	IrCompression,
	LoadCoreModule,
	ReferenceModule,
	SaveCoreModule,
	SaveCoreModuleBinSource,
	TrackLiveness,
	LoopInversion, // bool, enable loop inversion optimization
	// Deprecated
	ParameterBlocksUseRegisterSpaces,
	CountOfParsableOptions,
	// Used in parsed options only.
	DebugInformationFormat,  // intValue0: DebugInfoFormat
	VulkanBindShiftAll,      // intValue0: kind; intValue1: shift
	GenerateWholeProgram,    // bool
	UseUpToDateBinaryModule, // bool, when set, will only load
							 // precompiled modules if it is up-to-date with its source.
	EmbedDownstreamIR,       // bool
	ForceDXLayout,           // bool
	// Add this new option to the end of the list to avoid breaking ABI as much as possible.
	// Setting of EmitSpirvDirectly or EmitSpirvViaGLSL will turn into this option internally.
	EmitSpirvMethod, // enum SlangEmitSpirvMethod
}

CompilerOptionValueKind :: enum {
	Int,
	String,
}

FAILED :: #force_inline proc "contextless"(#any_int status: int) -> bool { return status < 0 }
SUCCEEDED :: #force_inline proc "contextless"(#any_int status: int) -> bool { return status >= 0 }
// Note(Dragos): is Result the correct type for these?
GET_RESULT_FACILITY :: #force_inline proc "contextless"(r: Result) -> i32 { return  (i32(r) >> 16) & 0x7fff }
GET_RESULT_CODE :: #force_inline proc "contextless"(r: Result) -> i32 { return i32(r) & 0xffff }

// TODO(Dragos): submit some issue related to i32(0x80000000)
// TODO(Dragos): check correctness of this, it seems fucked
MAKE_ERROR :: #force_inline proc "contextless"(fac: i32, code: i32) -> i32 { return (fac << 16) | i32(cast(u32)code | u32(0x80000000)) }
MAKE_SUCCESS :: #force_inline proc "contextless"(fac: i32, code: i32) -> i32 { return (fac << 16) | code }


// Note(Dragos): should we add an enum for these? Are these "macros" used often?
FACILITY_WIN_GENERAL :: 0
FACILITY_WIN_INTERFACE :: 4
FACILITY_WIN_API :: 7
FACILITY_BASE :: 0x200
FACILITY_CORE :: FACILITY_BASE
FACILITY_INTERNAL :: FACILITY_BASE + 1
FACILITY_EXTERNAL_BASE :: 0x210

OK :: 0
FAIL :: #force_inline proc "contextless"() -> i32 { return MAKE_ERROR(FACILITY_WIN_GENERAL, 0x4005) } 
MAKE_WIN_GENERAL_ERROR :: #force_inline proc "contextless"(code: i32) -> i32 { return MAKE_ERROR(FACILITY_WIN_GENERAL, code)}

// Note(dragos): We can hardcode these and put them in an enum. This is not the way.
E_NOT_IMPLEMENTED :: #force_inline proc "contextless"() -> i32 { return MAKE_WIN_GENERAL_ERROR(0x4001) }
E_NO_INTERFACE :: #force_inline proc "contextless"() -> i32 { return MAKE_WIN_GENERAL_ERROR(0x4002) }
E_ABORT :: #force_inline proc "contextless"() ->  i32 { return MAKE_WIN_GENERAL_ERROR(0x4004) }
E_INVALID_HANDLE :: #force_inline proc "contextless"() -> i32 { return MAKE_ERROR(FACILITY_WIN_API, 6) }
E_INVALID_ARG :: #force_inline proc "contextless"() -> i32 { return MAKE_ERROR(FACILITY_WIN_API, 0x57) }
E_OUT_OF_MEMORY :: #force_inline proc "contextless"() -> i32 { return MAKE_ERROR(FACILITY_WIN_API, 0xe) }

MAKE_CORE_ERROR :: #force_inline proc "contextless"(code: i32) -> i32 { return MAKE_ERROR(FACILITY_CORE, code) }

E_BUFFER_TOO_SMALL :: #force_inline proc "contextless"() -> i32 { return MAKE_CORE_ERROR(1) }
E_UNINITIALIZED :: #force_inline proc "contextless"() -> i32 { return MAKE_CORE_ERROR(2) }
E_PENDING :: #force_inline proc "contextless"() -> i32 { return MAKE_CORE_ERROR(3) }
E_CANNOT_OPEN :: #force_inline proc "contextless"() -> i32 { return MAKE_CORE_ERROR(4) }
E_NOT_FOUND :: #force_inline proc "contextless"() -> i32 { return MAKE_CORE_ERROR(5) }
E_INTERNAL_FAIL :: #force_inline proc "contextless"() -> i32 { return MAKE_CORE_ERROR(6) }
E_NOT_AVAILABLE :: #force_inline proc "contextless"() -> i32 { return MAKE_CORE_ERROR(7) }
E_TIME_OUT :: #force_inline proc "contextless"() -> i32 { return MAKE_CORE_ERROR(8) }

CompilerOptionValue :: struct {
	kind: CompilerOptionValueKind,
	intValue: i32,
	intValue1: i32,
	stringValue0: cstring,
	stringValue1: cstring,
}

CompilerOptionEntry :: struct {
	name: CompilerOptionName,
	value: CompilerOptionValue,
}

IUnknown_VTable :: struct {
	QueryInterface: proc "stdcall" (this: ^IUnknown, riid: ^dxgi.IID, ppvObject: ^rawptr) -> Result,
	AddRef:         proc "stdcall" (this: ^IUnknown) -> u32,
	Release:        proc "stdcall" (this: ^IUnknown) -> u32,
}


IUnknown :: struct {
	using vtable: ^IUnknown_VTable,
}

IGlobalSession_VTable :: struct {
	createSession: proc "stdcall" (#by_ptr desc: SessionDesc, outSession: ^^ISession) -> Result,

}

IBlob :: struct #raw_union {

}

ICompilerRequest :: struct #raw_union {

}

ISharedLibraryLoader :: struct #raw_union {

}

IGlobalSession :: struct #raw_union {
	#subtype iunknown: IUnknown,
	using vtable: ^struct {
		createSession: proc "stdcall"(#by_ptr desc: SessionDesc, outSession: ^^ISession) -> Result,
		findProfile: proc "stdcall"(name: cstring) -> ProfileID,
		setDownstreamCompierPath: proc "stdcall"(passThrough: PassThrough, path: cstring),
		setDownstreamCompilerPrelude: proc "stdcall"(passThrough: PassThrough, preduleText: cstring),
		getDownstreamCompilerPrelude: proc "stdcall"(passThrough: PassThrough, outPrelude: ^^IBlob),
		getBuildTagString: proc "stdcall"() -> cstring,
		setDefaultDownstreamCompiler: proc "stdcall"(sourceLanguage: SourceLanguage, defaultCompiler: PassThrough) -> Result,
		getDefaultDownstreamCompiler: proc "stdcall"(sourceLanguage: SourceLanguage) -> PassThrough,
		setLanguagePrelude: proc "stdcall"(sourceLanguage: SourceLanguage, preludeText: cstring),
		getLanguagePrelude: proc "stdcall"(sourceLanguage: SourceLanguage, outPrelude: ^^IBlob),
		/* [deprecated] */ createCompilerRequest: proc "stdcall"(outCompilerRequest: ^^ICompilerRequest) -> Result,
		addBuiltins: proc "stdcall"(sourcePath: cstring, sourceString: cstring),
		setSharedLibraryLoader: proc "stdcall"(loader: ^ISharedLibraryLoader),
		getSharedLibraryLoader: proc "stdcall"() -> ^ISharedLibraryLoader,
		checkCompileTargetSupport: proc "stdcall"(target: CompileTarget) -> Result,
	},
}

SessionDesc :: struct {

}

ISession_VTable :: struct {

}

ISession :: struct #raw_union {
	#subtype iunknown: IUnknown,
	using vtable: ^ISession_VTable,
}

@(link_prefix="slang_")
@(default_calling_convention="c")
foreign libslang {
	createGlobalSession :: proc(apiVersion: Int, outGlobalSession: ^^IGlobalSession) -> Result ---
	shutdown :: proc() ---
}



