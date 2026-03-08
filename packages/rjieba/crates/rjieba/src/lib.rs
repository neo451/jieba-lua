use mlua::prelude::*;
use mlua::UserData;
use jieba_rs::Jieba;
use std::sync::Arc;

// 定义 UserData 类型
struct RJieba {
    jieba: Arc<Jieba>,
}

impl RJieba {
    fn new() -> Self {
        RJieba {
            jieba: Arc::new(Jieba::new()),
        }
    }
}

// 实现 UserData trait
impl UserData for RJieba {
    fn add_methods<M: mlua::UserDataMethods<Self>>(methods: &mut M) {
        methods.add_method("cut", |lua, this, (text, hmm): (String, Option<bool>)| {
            // 如果 hmm 是 nil，默认为 true
            let use_hmm = hmm.unwrap_or(true);

            // 执行分词
            let words = this.jieba.cut(&text, use_hmm);

            // 创建并返回 Lua 表
            let result = lua.create_sequence_from(words.into_iter().map(String::from))?;
            Ok(result)
        });

        // 可以添加更多方法
        methods.add_method("cut_all", |lua, this, text: String| {
            let words = this.jieba.cut_all(&text);
            let result = lua.create_sequence_from(words.into_iter().map(String::from))?;
            Ok(result)
        });

        methods.add_method("cut_for_search", |lua, this, (text, hmm): (String, Option<bool>)| {
            let use_hmm = hmm.unwrap_or(true);
            let words = this.jieba.cut_for_search(&text, use_hmm);
            let result = lua.create_sequence_from(words.into_iter().map(String::from))?;
            Ok(result)
        });
    }
}

#[mlua::lua_module]
fn rjieba(lua: &Lua) -> LuaResult<LuaTable> {
    let exports = lua.create_table()?;

    // 创建 Jieba 构造函数
    let jieba_class = lua.create_function(|lua, ()| {
        let rjieba = RJieba::new();
        lua.create_userdata(rjieba)
    })?;

    // 将构造函数设置为模块的 new 方法
    exports.set("Jieba", jieba_class)?;

    // 也可以提供默认的全局实例
    let default_instance = RJieba::new();
    exports.set("jieba", lua.create_userdata(default_instance)?)?;

    Ok(exports)
}
