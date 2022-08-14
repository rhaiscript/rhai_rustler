use evalexpr::EvalexprError;
use rustler::{Encoder, Env, Term};

mod atoms {
    rustler::atoms! {
        wrong_operator_amount,
        wrong_function_argument_amount,
        expected_string,
        expected_int,
        expected_float,
        expected_number,
        expected_number_or_string,
        expected_boolean,
        expected_tuple,
        exepcted_fixed_length_tuple,
        expected_empty,
        append_to_leaf_node,
        precedence_violation,
        variable_identifier_not_found,
        function_identefier_not_found,
        type_error,
        wrong_type_combination,
        unmatched_l_brace,
        unmatched_r_brace,
        missing_operator_outside_of_brace,
        unmatched_partial_token,
        addition_error,
        subtraction_error,
        negation_error,
        multiplication_error,
        division_error,
        modulation_error,
        invaild_regex,
        context_not_mutable,
        illegal_escape_sequence,
        custom_message,
        unknown,
    }
}

pub fn to_error_tuple(env: Env, err: evalexpr::EvalexprError) -> Term {
    match err {
        EvalexprError::WrongOperatorArgumentAmount { .. } => {
            make_reason_tuple(env, atoms::wrong_operator_amount(), err)
        }
        EvalexprError::WrongFunctionArgumentAmount { .. } => {
            make_reason_tuple(env, atoms::wrong_function_argument_amount(), err)
        }
        EvalexprError::ExpectedString { .. } => {
            make_reason_tuple(env, atoms::expected_string(), err)
        }
        EvalexprError::ExpectedInt { .. } => make_reason_tuple(env, atoms::expected_int(), err),
        EvalexprError::ExpectedFloat { .. } => make_reason_tuple(env, atoms::expected_float(), err),
        EvalexprError::ExpectedNumber { .. } => {
            make_reason_tuple(env, atoms::expected_number(), err)
        }
        EvalexprError::ExpectedNumberOrString { .. } => {
            make_reason_tuple(env, atoms::expected_number_or_string(), err)
        }
        EvalexprError::ExpectedBoolean { .. } => {
            make_reason_tuple(env, atoms::expected_boolean(), err)
        }
        EvalexprError::ExpectedTuple { .. } => make_reason_tuple(env, atoms::expected_tuple(), err),
        EvalexprError::ExpectedFixedLenTuple { .. } => {
            make_reason_tuple(env, atoms::exepcted_fixed_length_tuple(), err)
        }
        EvalexprError::ExpectedEmpty { .. } => make_reason_tuple(env, atoms::expected_empty(), err),
        EvalexprError::AppendedToLeafNode => {
            make_reason_tuple(env, atoms::append_to_leaf_node(), err)
        }
        EvalexprError::PrecedenceViolation => {
            make_reason_tuple(env, atoms::precedence_violation(), err)
        }
        EvalexprError::VariableIdentifierNotFound(_) => {
            make_reason_tuple(env, atoms::variable_identifier_not_found(), err)
        }

        EvalexprError::FunctionIdentifierNotFound(_) => {
            make_reason_tuple(env, atoms::function_identefier_not_found(), err)
        }
        EvalexprError::TypeError { .. } => make_reason_tuple(env, atoms::type_error(), err),
        EvalexprError::WrongTypeCombination { .. } => {
            make_reason_tuple(env, atoms::wrong_type_combination(), err)
        }
        EvalexprError::UnmatchedLBrace => make_reason_tuple(env, atoms::unmatched_l_brace(), err),
        EvalexprError::UnmatchedRBrace => make_reason_tuple(env, atoms::unmatched_r_brace(), err),
        EvalexprError::MissingOperatorOutsideOfBrace => {
            make_reason_tuple(env, atoms::missing_operator_outside_of_brace(), err)
        }
        EvalexprError::UnmatchedPartialToken { .. } => {
            make_reason_tuple(env, atoms::unmatched_partial_token(), err)
        }
        EvalexprError::AdditionError { .. } => make_reason_tuple(env, atoms::addition_error(), err),
        EvalexprError::SubtractionError { .. } => {
            make_reason_tuple(env, atoms::subtraction_error(), err)
        }
        EvalexprError::NegationError { argument: _ } => {
            make_reason_tuple(env, atoms::negation_error(), err)
        }
        EvalexprError::MultiplicationError { .. } => {
            make_reason_tuple(env, atoms::multiplication_error(), err)
        }
        EvalexprError::DivisionError { .. } => make_reason_tuple(env, atoms::division_error(), err),
        EvalexprError::ModulationError { .. } => {
            make_reason_tuple(env, atoms::modulation_error(), err)
        }
        EvalexprError::InvalidRegex { .. } => make_reason_tuple(env, atoms::invaild_regex(), err),
        EvalexprError::ContextNotMutable => {
            make_reason_tuple(env, atoms::context_not_mutable(), err)
        }
        EvalexprError::IllegalEscapeSequence(_) => {
            make_reason_tuple(env, atoms::illegal_escape_sequence(), err)
        }
        EvalexprError::CustomMessage(_) => make_reason_tuple(env, atoms::custom_message(), err),
        _ => make_reason_tuple(env, atoms::unknown(), err),
    }
}

fn make_reason_tuple(env: Env, atom: rustler::types::atom::Atom, err: EvalexprError) -> Term {
    (atom, err.to_string().encode(env)).encode(env)
}
