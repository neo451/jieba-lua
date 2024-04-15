import describe, it from require "busted"
jieba = require"jieba"

describe "test", ->
  it "should sep words", ->
    assert.are.same { "我", "爱", "北京", "天安门" }, jieba.lcut("我爱北京天安门")
