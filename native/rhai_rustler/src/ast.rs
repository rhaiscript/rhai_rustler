use std::sync::RwLock;

use rhai::AST;

pub struct ASTResource {
    pub ast: RwLock<AST>,
}
