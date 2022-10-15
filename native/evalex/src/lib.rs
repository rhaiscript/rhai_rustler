mod errors;
mod types;

use std::collections::HashMap;

use evalexpr::{
    build_operator_tree, eval_with_context_mut, ContextWithMutableVariables, HashMapContext,
};
use rhai::{Dynamic, Engine, EvalAltResult, Scope};
use rustler::{Env, ResourceArc, Term};

struct PrecompiledExpression {
    operator_tree: evalexpr::Node,
}

fn load(env: Env, _: Term) -> bool {
    rustler::resource!(PrecompiledExpression, env);
    true
}

#[rustler::nif]
fn eval<'a>(
    env: Env<'a>,
    expression: &str,
    context: HashMap<String, Term<'a>>,
) -> Result<Term<'a>, Term<'a>> {
    // Create an 'Engine'
    let engine = Engine::new();
    let mut scope = Scope::new();

    for (k, v) in &context {
        scope.push_constant_dynamic(k, to_dynamic(env, v));
    }

    match engine.run_with_scope(&mut scope, expression) {
        Ok(a) => dbg!(a),
        Err(e) => {
            dbg!(e);
        }
    };

    match eval_with_context_mut(expression, &mut build_hash_map_context(env, context)) {
        Ok(value) => Ok(types::from_value(env, &value)),
        Err(err) => Err(errors::to_error_tuple(env, err)),
    }
}

fn to_dynamic<'a>(env: Env<'a>, term: &Term<'a>) -> Dynamic {
    match Term::get_type(*term) {
        rustler::TermType::Binary => term
            .decode::<String>()
            .map(Dynamic::from)
            .expect("get_type() returned Binary but could not decode as string."),

        rustler::TermType::Atom => term
            .decode::<bool>()
            .map(Dynamic::from)
            .or_else(|_| {
                if *term == rustler::types::atom::nil().to_term(env) {
                    Ok(Dynamic::from(()))
                } else {
                    term.atom_to_string().map(Dynamic::from)
                }
            })
            .expect("get_type() returned Atom but could not decode as string, boolean or empty."),
        rustler::TermType::EmptyList => Dynamic::from(Vec::<Dynamic>::new()),
        rustler::TermType::Exception => Dynamic::from(()),
        rustler::TermType::Fun => Dynamic::from(()),
        rustler::TermType::List => {
            let items: Vec<Dynamic> = term
                .decode::<Vec<Term>>()
                .expect("get_type() returned List but could not decode as list.")
                .iter()
                .map(|item| to_dynamic(env, item))
                .collect();

            Dynamic::from(items)
        }
        rustler::TermType::Map => {
            let mut object_map = rhai::Map::new();

            for (k, v) in term
                .decode::<HashMap<String, Term>>()
                .expect("get_type() returned Number but could not decod Hashmap.")
            {
                object_map.insert(k.into(), to_dynamic(env, &v));
            }
            Dynamic::from(object_map)
        }
        rustler::TermType::Number => term
            .decode::<i64>()
            .map(Dynamic::from)
            .or_else(|_| term.decode::<f64>().map(Dynamic::from))
            .expect("get_type() returned Number but could not decode as integer or float."),

        rustler::TermType::Pid => Dynamic::from(()),
        rustler::TermType::Port => Dynamic::from(()),
        rustler::TermType::Ref => Dynamic::from(()),
        rustler::TermType::Tuple => todo!("Tuple"),
        rustler::TermType::Unknown => Dynamic::from(()),
    }
}

#[rustler::nif]
fn eval_precompiled_expression<'a>(
    env: Env<'a>,
    precompiled_expression: ResourceArc<PrecompiledExpression>,
    context: HashMap<String, Term<'a>>,
) -> Result<Term<'a>, Term<'a>> {
    match precompiled_expression
        .operator_tree
        .eval_with_context_mut(&mut build_hash_map_context(env, context))
    {
        Ok(value) => Ok(types::from_value(env, &value)),
        Err(err) => Err(errors::to_error_tuple(env, err)),
    }
}

#[rustler::nif]
fn precompile_expression<'a>(
    env: Env<'a>,
    expression: &str,
) -> Result<ResourceArc<PrecompiledExpression>, Term<'a>> {
    match build_operator_tree(expression) {
        Ok(operator_tree) => {
            let data = PrecompiledExpression { operator_tree };

            let arc = ResourceArc::new(data);
            Ok(arc)
        }
        Err(err) => Err(errors::to_error_tuple(env, err)),
    }
}

fn build_hash_map_context<'a>(env: Env<'a>, context: HashMap<String, Term<'a>>) -> HashMapContext {
    let mut hash_map_context = HashMapContext::new();

    for (k, v) in context {
        hash_map_context.set_value(k, types::to_value(env, &v)).ok();
    }

    hash_map_context
}

rustler::init!(
    "Elixir.EvalEx.Native",
    [eval, eval_precompiled_expression, precompile_expression],
    load = load
);
