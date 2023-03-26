use std::sync::Mutex;

use rhai::AST;
use rustler::ResourceArc;

pub struct ASTResource {
    pub ast: Mutex<AST>,
}

#[rustler::nif]
fn ast_empty() -> ResourceArc<ASTResource> {
    ResourceArc::new(ASTResource {
        ast: Mutex::new(AST::empty()),
    })
}

#[rustler::nif]
fn ast_set_source(resource: ResourceArc<ASTResource>, source: &str) {
    let mut ast = resource.ast.try_lock().unwrap();

    ast.set_source(source);
}

#[rustler::nif]
fn ast_clear_source(resource: ResourceArc<ASTResource>) {
    let mut ast = resource.ast.try_lock().unwrap();

    ast.clear_source();
}

#[rustler::nif]
fn ast_source(resource: ResourceArc<ASTResource>) -> Option<String> {
    let ast = resource.ast.try_lock().unwrap();

    ast.source().map(|s| s.to_string())
}
