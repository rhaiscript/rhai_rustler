use evalexpr::*;
use rustler::{Encoder, Env, MapIterator, Term, TermType};

#[rustler::nif]
fn eval<'a>(env: Env<'a>, string: &str, context: Term<'a>) -> Result<Term<'a>, String> {
    let mut context_map = HashMapContext::new();

    let map = MapIterator::new(context).expect("Should be a map in the argument");

    for (k, v) in map {
        let key: String = k.decode().or(Err("key should be a string"))?;

        let value: Value = match Term::get_type(v) {
            TermType::Binary => Value::from(v.decode::<String>().expect("Should be a string")),
            TermType::Number => {
                if let Ok(num) = v.decode() as Result<i64, rustler::Error> {
                    Value::from(num)
                } else {
                    Value::from(v.decode::<f64>().expect("Should be a number"))
                }
            }
            TermType::Atom => Value::from(v.decode::<bool>().expect("Should be a boolean")),
            _ => return Err("invalid type".to_string()),
        };

        context_map.set_value((key).to_string(), value).ok();
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
