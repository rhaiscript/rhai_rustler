mod errors;
mod types;

use evalexpr::{eval_with_context_mut, ContextWithMutableVariables, HashMapContext};
use rustler::{Env, MapIterator, Term};

#[rustler::nif]
fn eval<'a>(env: Env<'a>, string: &str, context: Term<'a>) -> Result<Term<'a>, Term<'a>> {
    let mut hash_map_context = HashMapContext::new();

    MapIterator::new(context)
        .expect("Should be a map in the argument")
        .for_each(|(k, v)| {
            let key: String = k.decode().expect("Should be a string");

            hash_map_context.set_value(key, types::to_value(env, &v)).ok();
        });

    match eval_with_context_mut(string, &mut hash_map_context) {
        Ok(value) => Ok(types::from_value(env, &value)),
        Err(err) => Err(errors::to_error_tuple(env, err)),
    }
}

rustler::init!("Elixir.EvalEx.Native", [eval]);
