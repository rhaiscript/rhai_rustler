mod errors;
mod types;

use std::collections::HashMap;

use rhai::{Dynamic, Engine, Scope};
use rustler::{Encoder, Env, ResourceArc, Term};

// struct PrecompiledExpression {
//     operator_tree: evalexpr::Node,
// }

// fn load(env: Env, _: Term) -> bool {
//     rustler::resource!(PrecompiledExpression, env);
//     true
// }

#[rustler::nif]
fn eval<'a>(
    env: Env<'a>,
    expression: &str,
    expression_scope: HashMap<String, Term<'a>>,
) -> Result<Term<'a>, Term<'a>> {
    // Create an 'Engine'
    let engine = Engine::new();
    let mut scope = Scope::new();

    // Add all the variables to the scope
    for (k, v) in &expression_scope {
        scope.push_constant_dynamic(k, types::to_dynamic(env, v));
    }

    match engine.eval_with_scope::<Dynamic>(&mut scope, expression) {
        Ok(result) => Ok(types::from_dynamic(env, result)),

        Err(e) => Err(errors::to_error(env, *e)),
    }
}

// fn to_error(env: Env, error: EvalAltResult) -> Term {
//     let error = errors::Error::new(error);
//     error.encode(env)
// }

// #[rustler::nif]
// fn eval_precompiled_expression<'a>(
//     env: Env<'a>,
//     precompiled_expression: ResourceArc<PrecompiledExpression>,
//     context: HashMap<String, Term<'a>>,
// ) -> Result<Term<'a>, Term<'a>> {
//     match precompiled_expression
//         .operator_tree
//         .eval_with_context_mut(&mut build_hash_map_context(env, context))
//     {
//         Ok(value) => Ok(types::from_value(env, &value)),
//         Err(err) => Err(errors::to_error_tuple(env, err)),
//     }
// }

// #[rustler::nif]
// fn precompile_expression<'a>(
//     env: Env<'a>,
//     expression: &str,
// ) -> Result<ResourceArc<PrecompiledExpression>, Term<'a>> {
//     match build_operator_tree(expression) {
//         Ok(operator_tree) => {
//             let data = PrecompiledExpression { operator_tree };

//             let arc = ResourceArc::new(data);
//             Ok(arc)
//         }
//         Err(err) => Err(errors::to_error_tuple(env, err)),
//     }
// }

// fn build_hash_map_context<'a>(env: Env<'a>, context: HashMap<String, Term<'a>>) -> HashMapContext {
//     let mut hash_map_context = HashMapContext::new();

//     for (k, v) in context {
//         hash_map_context.set_value(k, types::to_value(env, &v)).ok();
//     }

//     hash_map_context
// }

rustler::init!("Elixir.Rhai.Native", [eval]); //, load = load);
