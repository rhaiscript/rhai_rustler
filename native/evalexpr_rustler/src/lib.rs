use evalexpr::*;
use rustler::{Decoder, Encoder, Env, MapIterator, Term, TermType};

macro_rules! try_set_number {
    ($context_map:expr, $key:expr, $term:expr, $type:ty) => {
        if let Ok(num) = parse_number(&$term) as Result<$type, rustler::Error> {
            _ = $context_map.set_value((&$key).to_string(), Value::from(num));
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
                let value: String = v.decode().unwrap();
                _ = context_map.set_value(key, Value::from(value));
            }
            TermType::Number => {
                try_set_number!(context_map, key, v, f64);
                try_set_number!(context_map, key, v, i64);
            }
            TermType::Atom => {
                let value: bool = v.decode().unwrap();
                _ = context_map.set_value(key, Value::from(value));
            }
            _ => return Err("Invalid type".to_string()),
        };
    }

    match eval_with_context(string, &context_map) {
        Ok(Value::Boolean(value)) => Ok(value.encode(env)),
        Ok(Value::Int(value)) => Ok(value.encode(env)),
        Ok(Value::String(value)) => Ok(value.encode(env)),
        Ok(Value::Float(value)) => Ok(value.encode(env)),
        Ok(_) => Err("not impl".to_string()),
        Err(err) => Err(err.to_string()),
    }
}

fn parse_number<'a, T: Decoder<'a>>(term: &Term<'a>) -> Result<T, rustler::Error> {
    if !term.is_number() {
        return Err(rustler::Error::BadArg);
    }

    term.decode().or(Err(rustler::Error::BadArg))
}

rustler::init!("Elixir.Evalexpr", [eval]);
