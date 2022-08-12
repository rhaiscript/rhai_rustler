mod errors;
mod types;

use evalexpr::{eval_with_context, ContextWithMutableVariables, HashMapContext};
use rustler::{Env, MapIterator, Term};

#[rustler::nif]
fn eval<'a>(env: Env<'a>, string: &str, vars: Term<'a>) -> Result<Term<'a>, Term<'a>> {
    let mut context = HashMapContext::new();

    MapIterator::new(vars)
        .expect("Should be a map in the argument")
        .for_each(|(k, v)| {
            let key: String = k.decode().expect("Should be a string");

            context.set_value(key, types::to_value(env, &v)).ok();
        });

    match eval_with_context(string, &context) {
        Ok(value) => Ok(types::from_value(env, &value)),
        Err(err) => Err(errors::to_error_tuple(env, err)),
    }
}

rustler::init!("Elixir.EvalEx", [eval]);
