use std::sync::Mutex;

use rhai::{
    module_resolvers::{FileModuleResolver, ModuleResolversCollection},
    Dynamic, Engine,
};

use rhai_dylib::loader::{libloading::Libloading, Loader};
use rhai_dylib::module_resolvers::libloading::DylibModuleResolver;

use rustler::{Env, ResourceArc, Term};

use crate::{
    ast::ASTResource,
    error::RhaiRustlerError,
    scope::ScopeResource,
    types::{from_dynamic, to_dynamic},
};

#[cfg(target_os = "linux")]
const DYLIB_EXTENSION: &str = "so";
#[cfg(target_os = "macos")]
const DYLIB_EXTENSION: &str = "dylib";
#[cfg(target_os = "windows")]
const DYLIB_EXTENSION: &str = "dll";

pub struct EngineResource {
    pub engine: Mutex<Engine>,
}

#[rustler::nif]
fn engine_new() -> ResourceArc<EngineResource> {
    let mut engine = Engine::new();

    let mut resolvers_collection = ModuleResolversCollection::new();
    resolvers_collection.push(FileModuleResolver::new());
    resolvers_collection.push(DylibModuleResolver::new());
    engine.set_module_resolver(resolvers_collection);

    ResourceArc::new(EngineResource {
        engine: Mutex::new(engine),
    })
}

#[rustler::nif]
fn engine_register_global_module(
    resource: ResourceArc<EngineResource>,
    path: String,
) -> Result<(), RhaiRustlerError> {
    let mut engine = resource.engine.try_lock().unwrap();
    let mut loader = Libloading::new();

    let path = format!("{}.{}", path, DYLIB_EXTENSION);

    engine.register_global_module(loader.load(path)?);

    Ok(())
}

#[rustler::nif]
fn engine_register_static_module(
    resource: ResourceArc<EngineResource>,
    namespace: String,
    path: String,
) -> Result<(), RhaiRustlerError> {
    let mut engine = resource.engine.try_lock().unwrap();
    let mut loader = Libloading::new();

    let path = format!("{}.{}", path, DYLIB_EXTENSION);

    engine.register_static_module(namespace, loader.load(path)?);

    Ok(())
}

#[rustler::nif]
fn engine_compile(
    resource: ResourceArc<EngineResource>,
    script: &str,
) -> Result<ResourceArc<ASTResource>, RhaiRustlerError> {
    let engine = resource.engine.try_lock().unwrap();
    let ast = engine.compile(script)?;

    let ast_resource = ResourceArc::new(ASTResource {
        ast: Mutex::new(ast),
    });

    Ok(ast_resource)
}

#[rustler::nif]
fn engine_compile_with_scope(
    resource: ResourceArc<EngineResource>,
    scope_resource: ResourceArc<ScopeResource>,
    script: &str,
) -> Result<ResourceArc<ASTResource>, RhaiRustlerError> {
    let engine = resource.engine.try_lock().unwrap();
    let scope = scope_resource.scope.try_lock().unwrap();
    let ast = engine.compile_with_scope(&scope, script)?;

    let ast_resource = ResourceArc::new(ASTResource {
        ast: Mutex::new(ast),
    });

    Ok(ast_resource)
}

#[rustler::nif]
fn engine_compile_expression(
    resource: ResourceArc<EngineResource>,
    expression: &str,
) -> Result<ResourceArc<ASTResource>, RhaiRustlerError> {
    let engine = resource.engine.try_lock().unwrap();
    let ast = engine.compile_expression(expression)?;

    let ast_resource = ResourceArc::new(ASTResource {
        ast: Mutex::new(ast),
    });

    Ok(ast_resource)
}

#[rustler::nif]
fn engine_compile_expression_with_scope(
    resource: ResourceArc<EngineResource>,
    scope_resource: ResourceArc<ScopeResource>,
    expression: &str,
) -> Result<ResourceArc<ASTResource>, RhaiRustlerError> {
    let engine = resource.engine.try_lock().unwrap();
    let scope = scope_resource.scope.try_lock().unwrap();
    let ast = engine.compile_expression_with_scope(&scope, expression)?;

    let ast_resource = ResourceArc::new(ASTResource {
        ast: Mutex::new(ast),
    });

    Ok(ast_resource)
}

#[rustler::nif]
fn engine_compile_file(
    resource: ResourceArc<EngineResource>,
    path: &str,
) -> Result<ResourceArc<ASTResource>, RhaiRustlerError> {
    let engine = resource.engine.try_lock().unwrap();
    let ast = engine.compile_file(path.into())?;

    let ast_resource = ResourceArc::new(ASTResource {
        ast: Mutex::new(ast),
    });

    Ok(ast_resource)
}

#[rustler::nif]
fn engine_compile_file_with_scope(
    resource: ResourceArc<EngineResource>,
    scope_resource: ResourceArc<ScopeResource>,
    path: &str,
) -> Result<ResourceArc<ASTResource>, RhaiRustlerError> {
    let engine = resource.engine.try_lock().unwrap();
    let scope = scope_resource.scope.try_lock().unwrap();
    let ast = engine.compile_file_with_scope(&scope, path.into())?;

    let ast_resource = ResourceArc::new(ASTResource {
        ast: Mutex::new(ast),
    });

    Ok(ast_resource)
}

#[rustler::nif]
fn engine_compile_into_self_contained(
    resource: ResourceArc<EngineResource>,
    scope_resource: ResourceArc<ScopeResource>,
    script: &str,
) -> Result<ResourceArc<ASTResource>, RhaiRustlerError> {
    let engine = resource.engine.try_lock().unwrap();
    let scope = scope_resource.scope.try_lock().unwrap();
    let ast = engine.compile_into_self_contained(&scope, script)?;

    let ast_resource = ResourceArc::new(ASTResource {
        ast: Mutex::new(ast),
    });

    Ok(ast_resource)
}

#[rustler::nif]
fn engine_compile_scripts_with_scope(
    resource: ResourceArc<EngineResource>,
    scope_resource: ResourceArc<ScopeResource>,
    scripts: Vec<String>,
) -> Result<ResourceArc<ASTResource>, RhaiRustlerError> {
    let engine = resource.engine.try_lock().unwrap();
    let scope = scope_resource.scope.try_lock().unwrap();
    let ast = engine.compile_scripts_with_scope(&scope, scripts)?;

    let ast_resource = ResourceArc::new(ASTResource {
        ast: Mutex::new(ast),
    });

    Ok(ast_resource)
}

#[rustler::nif]
fn engine_compact_script(
    resource: ResourceArc<EngineResource>,
    script: &str,
) -> Result<String, RhaiRustlerError> {
    let engine = resource.engine.try_lock().unwrap();
    let result = engine.compact_script(script)?;

    Ok(result)
}

#[rustler::nif]
fn engine_eval<'a>(
    env: Env<'a>,
    resource: ResourceArc<EngineResource>,
    script: &str,
) -> Result<Term<'a>, RhaiRustlerError> {
    let engine = resource.engine.try_lock().unwrap();
    let result = engine.eval::<Dynamic>(script)?;

    Ok(from_dynamic(env, result))
}

#[rustler::nif]
fn engine_eval_with_scope<'a>(
    env: Env<'a>,
    engine_resource: ResourceArc<EngineResource>,
    scope_resource: ResourceArc<ScopeResource>,
    script: &str,
) -> Result<Term<'a>, RhaiRustlerError> {
    let engine = engine_resource.engine.try_lock().unwrap();
    let mut scope = scope_resource.scope.try_lock().unwrap();
    let result = engine.eval_with_scope::<Dynamic>(&mut scope, script)?;

    Ok(from_dynamic(env, result))
}

#[rustler::nif]
fn engine_eval_ast(
    env: Env,
    engine_resource: ResourceArc<EngineResource>,
    ast_resource: ResourceArc<ASTResource>,
) -> Result<Term, RhaiRustlerError> {
    let engine = engine_resource.engine.try_lock().unwrap();
    let ast = ast_resource.ast.try_lock().unwrap();

    let result = engine.eval_ast(&ast)?;

    Ok(from_dynamic(env, result))
}

#[rustler::nif]
fn engine_eval_ast_with_scope<'a>(
    env: Env<'a>,
    engine_resource: ResourceArc<EngineResource>,
    scope_resource: ResourceArc<ScopeResource>,
    ast_resource: ResourceArc<ASTResource>,
) -> Result<Term<'a>, RhaiRustlerError> {
    let engine = engine_resource.engine.try_lock().unwrap();
    let mut scope = scope_resource.scope.try_lock().unwrap();
    let ast = ast_resource.ast.try_lock().unwrap();

    let result = engine.eval_ast_with_scope::<Dynamic>(&mut scope, &ast)?;

    Ok(from_dynamic(env, result))
}

#[rustler::nif]
fn engine_eval_expression<'a>(
    env: Env<'a>,
    resource: ResourceArc<EngineResource>,
    expression: &str,
) -> Result<Term<'a>, RhaiRustlerError> {
    let engine = resource.engine.try_lock().unwrap();
    let result = engine.eval_expression::<Dynamic>(expression)?;

    Ok(from_dynamic(env, result))
}

#[rustler::nif]
fn engine_eval_expression_with_scope<'a>(
    env: Env<'a>,
    resource: ResourceArc<EngineResource>,
    scope_resource: ResourceArc<ScopeResource>,
    expression: &str,
) -> Result<Term<'a>, RhaiRustlerError> {
    let engine = resource.engine.try_lock().unwrap();
    let mut scope = scope_resource.scope.try_lock().unwrap();
    let result = engine.eval_expression_with_scope::<Dynamic>(&mut scope, expression)?;

    Ok(from_dynamic(env, result))
}

#[rustler::nif]
fn engine_eval_file<'a>(
    env: Env<'a>,
    resource: ResourceArc<EngineResource>,
    path: &str,
) -> Result<Term<'a>, RhaiRustlerError> {
    let engine = resource.engine.try_lock().unwrap();
    let result = engine.eval_file::<Dynamic>(path.into())?;

    Ok(from_dynamic(env, result))
}

#[rustler::nif]
fn engine_eval_file_with_scope<'a>(
    env: Env<'a>,
    resource: ResourceArc<EngineResource>,
    scope_resource: ResourceArc<ScopeResource>,
    path: &str,
) -> Result<Term<'a>, RhaiRustlerError> {
    let engine = resource.engine.try_lock().unwrap();
    let mut scope = scope_resource.scope.try_lock().unwrap();
    let result = engine.eval_file_with_scope::<Dynamic>(&mut scope, path.into())?;

    Ok(from_dynamic(env, result))
}

#[rustler::nif]
fn engine_run(resource: ResourceArc<EngineResource>, script: &str) -> Result<(), RhaiRustlerError> {
    let engine = resource.engine.try_lock().unwrap();
    engine.run(script)?;

    Ok(())
}

#[rustler::nif]
fn engine_run_with_scope(
    resource: ResourceArc<EngineResource>,
    scope_resource: ResourceArc<ScopeResource>,
    script: &str,
) -> Result<(), RhaiRustlerError> {
    let engine = resource.engine.try_lock().unwrap();
    let mut scope = scope_resource.scope.try_lock().unwrap();

    engine.run_with_scope(&mut scope, script)?;

    Ok(())
}

#[rustler::nif]
fn engine_run_ast(
    resource: ResourceArc<EngineResource>,
    ast_resource: ResourceArc<ASTResource>,
) -> Result<(), RhaiRustlerError> {
    let engine = resource.engine.try_lock().unwrap();
    let ast = ast_resource.ast.try_lock().unwrap();

    engine.run_ast(&ast)?;

    Ok(())
}

#[rustler::nif]
fn engine_run_ast_with_scope(
    resource: ResourceArc<EngineResource>,
    scope_resource: ResourceArc<ScopeResource>,
    ast_resource: ResourceArc<ASTResource>,
) -> Result<(), RhaiRustlerError> {
    let engine = resource.engine.try_lock().unwrap();
    let mut scope = scope_resource.scope.try_lock().unwrap();
    let ast = ast_resource.ast.try_lock().unwrap();

    engine.run_ast_with_scope(&mut scope, &ast)?;

    Ok(())
}

#[rustler::nif]
fn engine_run_file(
    resource: ResourceArc<EngineResource>,
    path: &str,
) -> Result<(), RhaiRustlerError> {
    let engine = resource.engine.try_lock().unwrap();
    engine.run_file(path.into())?;

    Ok(())
}

#[rustler::nif]
fn engine_run_file_with_scope(
    resource: ResourceArc<EngineResource>,
    scope_resource: ResourceArc<ScopeResource>,
    path: &str,
) -> Result<(), RhaiRustlerError> {
    let engine = resource.engine.try_lock().unwrap();
    let mut scope = scope_resource.scope.try_lock().unwrap();

    engine.run_file_with_scope(&mut scope, path.into())?;

    Ok(())
}

#[rustler::nif]
fn engine_call_fn<'a>(
    env: Env<'a>,
    resource: ResourceArc<EngineResource>,
    scope: ResourceArc<ScopeResource>,
    ast: ResourceArc<ASTResource>,
    name: &str,
    args: Vec<Term<'a>>,
) -> Result<Term<'a>, RhaiRustlerError> {
    let engine = resource.engine.try_lock().unwrap();
    let mut scope = scope.scope.try_lock().unwrap();
    let ast = ast.ast.try_lock().unwrap();

    let args: Vec<Dynamic> = args.into_iter().map(|arg| to_dynamic(env, &arg)).collect();

    let result = engine.call_fn(&mut scope, &ast, name, args)?;

    Ok(from_dynamic(env, result))
}

#[rustler::nif]
fn engine_set_allow_anonymous_fn(resource: ResourceArc<EngineResource>, enable: bool) {
    let mut engine = resource.engine.try_lock().unwrap();

    engine.set_allow_anonymous_fn(enable);
}

#[rustler::nif]
fn engine_allow_anonymous_fn(resource: ResourceArc<EngineResource>) -> bool {
    let engine = resource.engine.try_lock().unwrap();

    engine.allow_anonymous_fn()
}

#[rustler::nif]
fn engine_set_allow_if_expression(resource: ResourceArc<EngineResource>, enable: bool) {
    let mut engine = resource.engine.try_lock().unwrap();

    engine.set_allow_if_expression(enable);
}

#[rustler::nif]
fn engine_allow_if_expression(resource: ResourceArc<EngineResource>) -> bool {
    let engine = resource.engine.try_lock().unwrap();

    engine.allow_if_expression()
}

#[rustler::nif]
fn engine_set_allow_loop_expressions(resource: ResourceArc<EngineResource>, enable: bool) {
    let mut engine = resource.engine.try_lock().unwrap();

    engine.set_allow_loop_expressions(enable);
}

#[rustler::nif]
fn engine_allow_loop_expressions(resource: ResourceArc<EngineResource>) -> bool {
    let engine = resource.engine.try_lock().unwrap();

    engine.allow_loop_expressions()
}

#[rustler::nif]
fn engine_set_allow_looping(resource: ResourceArc<EngineResource>, enable: bool) {
    let mut engine = resource.engine.try_lock().unwrap();

    engine.set_allow_looping(enable);
}

#[rustler::nif]
fn engine_allow_looping(resource: ResourceArc<EngineResource>) -> bool {
    let engine = resource.engine.try_lock().unwrap();

    engine.allow_looping()
}

#[rustler::nif]
fn engine_set_allow_shadowing(resource: ResourceArc<EngineResource>, enable: bool) {
    let mut engine = resource.engine.try_lock().unwrap();

    engine.set_allow_shadowing(enable);
}

#[rustler::nif]
fn engine_allow_shadowing(resource: ResourceArc<EngineResource>) -> bool {
    let engine = resource.engine.try_lock().unwrap();

    engine.allow_shadowing()
}

#[rustler::nif]
fn engine_set_allow_statement_expression(resource: ResourceArc<EngineResource>, enable: bool) {
    let mut engine = resource.engine.try_lock().unwrap();

    engine.set_allow_statement_expression(enable);
}

#[rustler::nif]
fn engine_allow_statement_expression(resource: ResourceArc<EngineResource>) -> bool {
    let engine = resource.engine.try_lock().unwrap();

    engine.allow_statement_expression()
}

#[rustler::nif]
fn engine_set_allow_switch_expression(resource: ResourceArc<EngineResource>, enable: bool) {
    let mut engine = resource.engine.try_lock().unwrap();

    engine.set_allow_switch_expression(enable);
}

#[rustler::nif]
fn engine_allow_switch_expression(resource: ResourceArc<EngineResource>) -> bool {
    let engine = resource.engine.try_lock().unwrap();

    engine.allow_switch_expression()
}

#[rustler::nif]
fn engine_set_fail_on_invalid_map_property(resource: ResourceArc<EngineResource>, enable: bool) {
    let mut engine = resource.engine.try_lock().unwrap();

    engine.set_fail_on_invalid_map_property(enable);
}

#[rustler::nif]
fn engine_fail_on_invalid_map_property(resource: ResourceArc<EngineResource>) -> bool {
    let engine = resource.engine.try_lock().unwrap();

    engine.fail_on_invalid_map_property()
}

#[rustler::nif]
fn engine_set_fast_operators(resource: ResourceArc<EngineResource>, enable: bool) {
    let mut engine = resource.engine.try_lock().unwrap();

    engine.set_fast_operators(enable);
}

#[rustler::nif]
fn engine_fast_operators(resource: ResourceArc<EngineResource>) -> bool {
    let engine = resource.engine.try_lock().unwrap();

    engine.fast_operators()
}

#[rustler::nif]
fn engine_set_max_array_size(resource: ResourceArc<EngineResource>, max_size: usize) {
    let mut engine = resource.engine.try_lock().unwrap();

    engine.set_max_array_size(max_size);
}

#[rustler::nif]
fn engine_max_array_size(resource: ResourceArc<EngineResource>) -> usize {
    let engine = resource.engine.try_lock().unwrap();

    engine.max_array_size()
}

#[rustler::nif]
fn engine_set_max_call_levels(resource: ResourceArc<EngineResource>, levels: usize) {
    let mut engine = resource.engine.try_lock().unwrap();

    engine.set_max_call_levels(levels);
}

#[rustler::nif]
fn engine_max_call_levels(resource: ResourceArc<EngineResource>) -> usize {
    let engine = resource.engine.try_lock().unwrap();

    engine.max_call_levels()
}

#[rustler::nif]
fn engine_set_max_expr_depths(
    resource: ResourceArc<EngineResource>,
    max_expr_depth: usize,
    max_function_expr_depth: usize,
) {
    let mut engine = resource.engine.try_lock().unwrap();

    engine.set_max_expr_depths(max_expr_depth, max_function_expr_depth);
}

#[rustler::nif]
fn engine_max_expr_depth(resource: ResourceArc<EngineResource>) -> usize {
    let engine = resource.engine.try_lock().unwrap();

    engine.max_expr_depth()
}

#[rustler::nif]
fn engine_max_function_expr_depth(resource: ResourceArc<EngineResource>) -> usize {
    let engine = resource.engine.try_lock().unwrap();

    engine.max_function_expr_depth()
}

#[rustler::nif]
fn engine_set_max_map_size(resource: ResourceArc<EngineResource>, max_size: usize) {
    let mut engine = resource.engine.try_lock().unwrap();

    engine.set_max_map_size(max_size);
}

#[rustler::nif]
fn engine_max_map_size(resource: ResourceArc<EngineResource>) -> usize {
    let engine = resource.engine.try_lock().unwrap();

    engine.max_map_size()
}

#[rustler::nif]
fn engine_set_max_modules(resource: ResourceArc<EngineResource>, modules: usize) {
    let mut engine = resource.engine.try_lock().unwrap();

    engine.set_max_modules(modules);
}

#[rustler::nif]
fn engine_max_modules(resource: ResourceArc<EngineResource>) -> usize {
    let engine = resource.engine.try_lock().unwrap();

    engine.max_modules()
}

#[rustler::nif]
fn engine_set_max_operations(resource: ResourceArc<EngineResource>, operations: u64) {
    let mut engine = resource.engine.try_lock().unwrap();

    engine.set_max_operations(operations);
}

#[rustler::nif]
fn engine_max_operations(resource: ResourceArc<EngineResource>) -> u64 {
    let engine = resource.engine.try_lock().unwrap();

    engine.max_operations()
}

#[rustler::nif]
fn engine_set_max_string_size(resource: ResourceArc<EngineResource>, max_len: usize) {
    let mut engine = resource.engine.try_lock().unwrap();

    engine.set_max_string_size(max_len);
}

#[rustler::nif]
fn engine_max_string_size(resource: ResourceArc<EngineResource>) -> usize {
    let engine = resource.engine.try_lock().unwrap();

    engine.max_string_size()
}

#[rustler::nif]
fn engine_set_strict_variables(resource: ResourceArc<EngineResource>, enable: bool) {
    let mut engine = resource.engine.try_lock().unwrap();

    engine.set_strict_variables(enable);
}

#[rustler::nif]
fn engine_strict_variables(resource: ResourceArc<EngineResource>) -> bool {
    let engine = resource.engine.try_lock().unwrap();

    engine.strict_variables()
}
