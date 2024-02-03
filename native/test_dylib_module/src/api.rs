use rhai_dylib::rhai::plugin::*;
use rhai_dylib::rhai::{Map, Module, INT};

#[derive(Clone)]
pub struct MyPluginObjectInner {
    inner: String,
}

// The plugin API from rhai can be used to create your plugin API.
#[rhai_dylib::rhai::export_module]
pub mod my_plugin_api {

    // Implement a custom type.
    type MyPluginObject = MyPluginObjectInner;

    // Constructor for the custom type.
    #[rhai_fn(global)]
    pub fn new_plugin_object(inner: &str) -> MyPluginObject {
        MyPluginObject {
            inner: inner.to_string(),
        }
    }

    /// A function for the custom type.
    #[rhai_fn(global)]
    pub fn get_inner(s: MyPluginObject) -> String {
        s.inner
    }

    /// Computing something and returning a result.
    #[rhai_fn(global)]
    pub fn triple_add(a: INT, b: INT, c: INT) -> INT {
        a + b + c
    }

    /// Custom operator
    #[rhai_fn(name = "#", global)]
    pub fn custom_operator(a: INT, b: INT) -> INT {
        a + b
    }

    /// Using Rhai types, non-global function.
    #[rhai_fn()]
    pub fn get_property(m: &mut Map) -> String {
        m.get("property").unwrap().clone_cast()
    }
}
