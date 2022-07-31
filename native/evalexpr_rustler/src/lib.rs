use evalexpr::*;
use rustler::{Encoder, Env, MapIterator, Term, TermType};

macro_rules! set_value {
    ($context_map:expr, $key:expr, $term:expr, $type:ty) => {
        if let Ok(num) = $term.decode() as Result<$type, rustler::Error> {
            _ = $context_map.set_value((&$key).to_string(), Value::from(num));
        } else {
            panic!("expected type: {}", stringify!($type));
        }
    };
}

#[rustler::nif]
fn eval<'a>(env: Env<'a>, string: &str, context: Term<'a>) -> Result<Term<'a>, String> {
    let mut context_map = HashMapContext::new();

    let map = MapIterator::new(context).expect("Should be a map in the argument");

    for (k, v) in map {
        let key: String = k.decode().unwrap();

        match Term::get_type(v) {
            TermType::Binary => {
                set_value!(context_map, key, v, String);
            }
            TermType::Number => {
                set_value!(context_map, key, v, f64);
                set_value!(context_map, key, v, i64);
            }
            TermType::Atom => {
                set_value!(context_map, key, v, bool);
            }
            _ => return Err("invalid type".to_string()),
        };
    }

    match eval_with_context(string, &context_map) {
        Ok(Value::Boolean(value)) => Ok(value.encode(env)),
        Ok(Value::Int(value)) => Ok(value.encode(env)),
        Ok(Value::String(value)) => Ok(value.encode(env)),
        Ok(Value::Float(value)) => Ok(value.encode(env)),
        Ok(_) => Err("not implemented".to_string()),
        Err(err) => Err(err.to_string()),
    }
}

rustler::init!("Elixir.Evalexpr", [eval]);
