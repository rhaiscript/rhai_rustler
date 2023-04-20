mod ast;
mod engine;
mod error;
mod scope;
mod types;

use std::collections::HashMap;

use rhai::config::hashing::set_ahash_seed;
use rhai::{Dynamic, Engine, Scope};
use rustler::{Env, Term};

use crate::ast::*;
use crate::engine::*;
use crate::error::RhaiRustlerError;
use crate::scope::*;

#[rustler::nif]
fn eval<'a>(
    env: Env<'a>,
    expression: &str,
    expression_scope: HashMap<String, Term<'a>>,
) -> Result<Term<'a>, RhaiRustlerError> {
    // Create an 'Engine'
    let mut engine = Engine::new();
    engine.set_fail_on_invalid_map_property(true);
    let engine = engine;

    let mut scope = Scope::new();

    // Add variables to the scope
    for (k, v) in &expression_scope {
        scope.push_dynamic(k, types::to_dynamic(env, v));
    }

    let result = engine.eval_with_scope::<Dynamic>(&mut scope, expression)?;

    Ok(types::from_dynamic(env, result))
}

fn load(env: Env, _: Term) -> bool {
    // Set dylib ahash seed
    if let Err(value) = set_ahash_seed(Some([1, 3, 3, 7])) {
        eprintln!(
            "Failed to set ahash seed, ahash seed already set: {:?}",
            value
        );
        return false;
    }

    rustler::resource!(EngineResource, env);
    rustler::resource!(ScopeResource, env);
    rustler::resource!(ASTResource, env);

    true
}

rustler::init!(
    "Elixir.Rhai.Native",
    [
        // legacy
        eval,
        // engine
        engine_new,
        engine_new_raw,
        engine_compile,
        engine_compile_with_scope,
        engine_compile_expression,
        engine_compile_expression_with_scope,
        engine_compile_file,
        engine_compile_file_with_scope,
        engine_compile_into_self_contained,
        engine_compile_scripts_with_scope,
        engine_compact_script,
        engine_register_global_module,
        engine_register_static_module,
        engine_register_custom_operator,
        engine_eval,
        engine_eval_with_scope,
        engine_eval_ast,
        engine_eval_ast_with_scope,
        engine_eval_expression,
        engine_eval_expression_with_scope,
        engine_eval_file,
        engine_eval_file_with_scope,
        engine_run,
        engine_run_with_scope,
        engine_run_ast,
        engine_run_ast_with_scope,
        engine_run_file,
        engine_run_file_with_scope,
        engine_call_fn,
        engine_set_fail_on_invalid_map_property,
        engine_fail_on_invalid_map_property,
        engine_set_max_array_size,
        engine_max_array_size,
        engine_set_allow_anonymous_fn,
        engine_allow_anonymous_fn,
        engine_set_allow_if_expression,
        engine_allow_if_expression,
        engine_set_allow_loop_expressions,
        engine_allow_loop_expressions,
        engine_set_allow_looping,
        engine_allow_looping,
        engine_set_allow_shadowing,
        engine_allow_shadowing,
        engine_set_allow_statement_expression,
        engine_allow_statement_expression,
        engine_set_allow_switch_expression,
        engine_allow_switch_expression,
        engine_set_fast_operators,
        engine_fast_operators,
        engine_set_max_call_levels,
        engine_max_call_levels,
        engine_set_max_expr_depths,
        engine_max_expr_depth,
        engine_max_function_expr_depth,
        engine_set_max_map_size,
        engine_max_map_size,
        engine_set_max_modules,
        engine_max_modules,
        engine_set_max_operations,
        engine_max_operations,
        engine_set_max_string_size,
        engine_max_string_size,
        engine_set_strict_variables,
        engine_strict_variables,
        engine_optimization_level,
        engine_set_optimization_level,
        engine_optimize_ast,
        engine_disable_symbol,
        engine_ensure_data_size_within_limits,
        // scope
        scope_new,
        scope_with_capacity,
        scope_push_dynamic,
        scope_push_constant_dynamic,
        scope_contains,
        scope_is_constant,
        scope_get_value,
        scope_clear,
        scope_clone_visible,
        scope_is_empty,
        scope_len,
        scope_remove,
        scope_rewind,
        scope_pop,
        scope_set_value,
        scope_set_or_push,
        scope_iter_collect,
        // AST
        ast_empty,
        ast_source,
        ast_set_source,
        ast_clear_source,
        ast_merge,
        ast_combine,
        ast_clear_functions,
        ast_clear_statements,
        ast_clone_functions_only,
        ast_has_functions,
    ],
    load = load
);
