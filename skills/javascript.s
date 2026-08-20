# Vanilla JavaScript Knowledge Base
@meta |topic:javascript|versions:ES3-ES5-ES6-ES2020+|lastUpdated:2026-08-18|confidence:high|
@esVersions |
  es3:no let/const, no arrow, no template, no class, no module
  es5:strict mode, JSON, array extras (map/filter/forEach), Object.keys/defineProperty, getter/setter, bind/call/apply
  es6:let/const, arrow, template, class, import/export, promise, destructuring, spread, default/rest params, for...of, symbol, iterator, map/set/weakmap/weakset
  es2017:async/await, Object.entries/values, padStart/padEnd, Object.getOwnPropertyDescriptors
  es2018:rest/spread properties, async iteration (for await), Promise.finally
  es2019:Array.flat/flatMap, Object.fromEntries, optional catch binding, trimStart/trimEnd
  es2020:optional chaining (?.), nullish coalescing (??), Promise.allSettled/any, BigInt, globalThis
  es2021:replaceAll, Promise.any, numeric separators (1_000), logical assignment (??=)
  es2022:Object.hasOwn, Array.at, top-level await, private class fields (#)
  es2023:Array.findLast/last, toReversed/toSorted/toSpliced
  es2024:Object.groupBy, Promise.withResolvers, ArrayBuffer resize
  esNext:decorators, import.meta, pipeline operator (proposal)
|
@es5 |
  strictMode:"use strict" (no silent errors, no with, no eval scope)
  json:JSON.parse(), JSON.stringify()
  arrayExtras:map, filter, forEach, reduce, every, some, indexOf, isArray
  objectKeys:Object.keys(obj)
  objectDefine:Object.defineProperty(obj, key, descriptor)
  objectCreate:Object.create(proto)
  getterSetter:get prop() {}, set prop(val) {}
  bind:func.bind(thisArg)
  stringTrim:String.prototype.trim()
  dateNow:Date.now()
  isoDate:date.toISOString()
|
@es6 |
  letConst:let x = 1 (block scope), const x = 1 (no reassign)
  arrow:(x) => x * 2
  template:`hello ${name}`
  destructuring:const { a, b } = obj; const [x, y] = arr
  spread:const arr = [...a, ...b]; const obj = {...a, ...b}
  defaultParams:function(a = 1) {}
  restParams:function(...args) {}
  class:class Foo { constructor() {} }
  importExport:import { name } from 'mod'; export default name
  promise:new Promise((resolve, reject) => {})
  forOf:for (const x of iterable) {}
  symbol:Symbol('id')
  iterator:iterable[Symbol.iterator]()
  mapSet:new Map(), new Set()
  weakMap:new WeakMap(), new WeakSet()
  arrayFrom:Array.from(iterable)
  arrayOf:Array.of(1, 2, 3)
  objectEntries:Object.entries(obj)
  objectValues:Object.values(obj)
  stringIncludes:str.includes('sub')
  stringStartsEnds:str.startsWith('pre'), str.endsWith('suf')
  regexpFlags:RegExp flags (g, i, m, u, y)
  tailCall:tail call optimization (limited support, Safari only)
|
@es2015plus |
  es2017:async/await, Object.entries/values, padStart/padEnd
  es2018:rest/spread properties, for await...of, Promise.finally
  es2019:flat/flatMap, Object.fromEntries, optional catch binding
  es2020:?.  ??, Promise.allSettled/any, BigInt, globalThis
  es2021:replaceAll, Promise.any, numeric separators, ??= &&= ||=
  es2022:Object.hasOwn, Array.at, top-level await, #private
  es2023:findLast/last, toReversed/toSorted/toSpliced
  es2024:Object.groupBy, Promise.withResolvers
|
@es6Features |
  arrow:(x) => x * 2
  arrowThis:arrow functions don't bind `this`
  destructuring:const { name, age } = person
  destructuringArr:const [first, ...rest] = array
  spread:const newArr = [...arr1, ...arr2]
  spreadObj:const newObj = { ...obj1, ...obj2 }
  default:function greet(name = "world") {}
  rest:function sum(...args) {}
  template:`Hello ${name}, you are ${age}`
  shorthand:const name = name (object shorthand)
  computedProp:const key = "name"; const obj = { [key]: "value" }
  import:import { func } from "./module"
  export:export const name = value
  exportDefault:export default function() {}
  class:class Person { constructor(name) { this.name = name } }
  classExtend:class Child extends Parent {}
  promise:new Promise((resolve, reject) => {...})
  async:async function name() { await ... }
  forOf:for (const item of array) {}
  map:array.map(x => x * 2)
  filter:array.filter(x => x > 5)
  reduce:array.reduce((acc, x) => acc + x, 0)
  find:array.find(x => x > 5)
  includes:array.includes(value)
  objectEntries:Object.entries(obj)
  objectKeys:Object.keys(obj)
  objectValues:Object.values(obj)
  optionalChain:obj?.name?.first
  nullish:name ?? "default"
  dynamicImport:await import("./module")
|
@variables |
  scope:var (function), let/const (block)
  hoisting:var hoisted, let/const TDZ
  closure:inner function retains outer scope
  global:var x = 1 (window.x), let x = 1 (no window)
  naming:camelCase for variables, PascalCase for classes
  namingConst:UPPER_SNAKE for true constants
|
@functions |
  declaration:function name() {} (hoisted)
  expression:const name = function() {} (not hoisted)
  arrow:const name = () => {}
  arrowMultiLine:const name = () => { return value }
  IIFE:(function() { ... })()
  callback:array.forEach((item) => { ... })
  higherOrder:fn that takes/returns fn
  closure:fn that remembers outer scope
  bind:func.bind(thisArg, arg1)
  call:func.call(thisArg, arg1, arg2)
  apply:func.apply(thisArg, [args])
  partialApply:const bound = func.bind(null, arg1)
|
@arrays |
  create:const arr = [1, 2, 3]
  access:arr[0]
  length:arr.length
  push:arr.push(4)
  pop:arr.pop()
  shift:arr.shift()
  unshift:arr.unshift(0)
  splice:arr.splice(1, 2, "a", "b") // start, delete, insert
  slice:arr.slice(1, 3) // copy without mutating
  concat:arr1.concat(arr2)
  flat:arr.flat(Infinity)
  flatMap:arr.flatMap(x => [x, x * 2])
  sort:arr.sort((a, b) => a - b)
  reverse:arr.reverse()
  includes:arr.includes(value)
  indexOf:arr.indexOf(value)
  find:arr.find(x => x > 5)
  .findIndex:arr.findIndex(x => x > 5)
  every:arr.every(x => x > 0)
  some:arr.some(x => x > 5)
  map:arr.map(x => x * 2)
  filter:arr.filter(x => x > 5)
  reduce:arr.reduce((acc, x) => acc + x, 0)
  forEach:arr.forEach(x => console.log(x))
  join:arr.join(", ")
  split:str.split(", ")
  from:Array.from(arrayLike)
  of:Array.of(1, 2, 3)
  fill:arr.fill(0, 1, 3) // value, start, end
  copyWithin:arr.copyWithin(1, 3) // target, start
  entries:arr.entries() // iterator with index
  keys:arr.keys() // iterator of indices
  values:arr.values() // iterator of values
  arrayDestructure:const [a, b, ...rest] = arr
  swap:[arr[i],arr[j]] = [arr[j],arr[i]]
|
@objects |
  create:const obj = {}
  createFrom:Object.create(proto)
  literal:const obj = { name: "John", age: 30 }
  access:obj.name or obj["name"]
  dynamicAccess:obj[variable]
  add:obj.newKey = "value"
  delete:delete obj.key
  check:"key" in obj
  hasOwn:Object.hasOwn(obj, "key") (ES2022)
  keys:Object.keys(obj)
  values:Object.values(obj)
  entries:Object.entries(obj)
  fromEntries:Object.fromEntries(entries)
  assign:Object.assign(target, source)
  spread:{...obj1:True,...obj2:True}
  freeze:Object.freeze(obj)
  isFrozen:Object.isFrozen(obj)
  seal:Object.seal(obj)
  isSealed:Object.isSealed(obj)
  define:Object.defineProperty(obj, key, descriptor)
  descriptor:{value:True,writable:True,enumerable:True,configurable:True}
  getter:get prop() { return this._prop }
  setter:set prop(val) { this._prop = val }
  shorthand:const name = "John"; const obj = { name }
  computed:{[dynamicKey]:value}
|
@strings |
  create:const s = "hello"
  template:`hello ${name}`
  length:s.length
  access:s[0]
  includes:s.includes("ell")
  startsWith:s.startsWith("hel")
  endsWith:s.endsWith("llo")
  indexOf:s.indexOf("ell")
  slice:s.slice(1, 3)
  substring:s.substring(1, 3)
  toUpperCase:s.toUpperCase()
  toLowerCase:s.toLowerCase()
  trim:s.trim()
  trimStart:s.trimStart()
  trimEnd:s.trimEnd()
  replace:s.replace("hello", "hi")
  replaceAll:s.replaceAll("l", "r")
  split:s.split(" ")
  repeat:s.repeat(3)
  padStart:s.padStart(10, "0")
  padEnd:s.padEnd(10, "0")
  charAt:s.charAt(0)
  charCodeAt:s.charCodeAt(0)
  match:s.match(/regex/g)
  matchAll:[...s.matchAll(/regex/g)]
  search:s.search(/regex/)
  raw:String.raw`hello\nworld`
|
@numbers |
  parseInt:parseInt("10", 10)
  parseFloat:parseFloat("3.14")
  isFinite:Number.isFinite(value)
  isInteger:Number.isInteger(value)
  isNaN:Number.isNaN(value) (not global isNaN)
  toFixed:(3.14).toFixed(2) // "3.14"
  toPrecision:(3.14).toPrecision(2) // "3.1"
  toString:(10).toString(2) // "1010"
  max:Math.max(...array)
  min:Math.min(...array)
  random:Math.random()
  floor:Math.floor(3.9) // 3
  ceil:Math.ceil(3.1) // 4
  round:Math.round(3.5) // 4
  abs:Math.abs(-5) // 5
  sqrt:Math.sqrt(9) // 3
  pow:Math.pow(2, 3) // 8
  trunc:Math.trunc(3.9) // 3
  sign:Math.sign(-5) // -1
|
@async |
  promise:new Promise((resolve, reject) => {...})
  then:promise.then(result => {...})
  catch:promise.catch(error => {...})
  finally:promise.finally(() => {...})
  asyncFn:async function name() { await ... }
  await:const result = await promise
  parallel:const [a, b] = await Promise.all([p1, p2])
  parallelSettled:await Promise.allSettled([p1, p2])
  race:await Promise.race([p1, p2])
  any:await Promise.any([p1, p2])
  queue:p-limit for concurrency control
  abort:AbortController for cancellation
  abortUsage:signal: controller.signal
  eventTarget:new EventTarget()
  eventListen:target.addEventListener("event", handler)
  eventDispatch:target.dispatchEvent(new Event("event"))
|
@errors |
  tryCatch:try { ... } catch (e) { ... }
  finally:try { ... } finally { ... }
  throw:throw new Error("message")
  custom:class MyError extends Error {}
  cause:new Error("msg", { cause: originalError })
  stack:error.stack
  name:error.name
  message:error.message
  instanceof:error instanceof TypeError
  aggregateError:AggregateError [errors]
  uncaught:window.addEventListener("error", handler)
  unhandled:window.addEventListener("unhandledrejection", handler)
|
@modules |
  export:export const name = value
  exportDefault:export default function() {}
  exportNamed:export { name1, name2 }
  reExport:export { name } from "./module"
  import:import { name } from "./module"
  importDefault:import name from "./module"
  importAll:import * as mod from "./module"
  dynamicImport:const mod = await import("./module")
  sideEffect:import "./module"
  type:export type { Name } from "./module"
|
@iterators |
  forOf:for (const item of array) {}
  entries:for (const [i, v] of array.entries()) {}
  keys:for (const k of Object.keys(obj)) {}
  values:for (const v of Object.values(obj)) {}
  entries2:for (const [k, v] of Object.entries(obj)) {}
  spread:[...arrayLike]
  from:Array.from(iterable)
  next:iterator.next() // { value, done }
|
@gotchas |
  thisFix:use regular functions for methods
  comparison:== does type coercion
  comparisonFix:always use ===
  hoisting:var is hoisted, let/const are TDZ
  nullCheck:typeof null === "object" (bug)
  nullFix:value === null
  arraySort:sort() converts to strings
  parseFloat:parseFloat("10px") // 10 (no error)
  parseFloatFix:parseInt(value, 10)
  spreadObject:spread doesn't deep clone
  spreadClone:structuredClone({...obj}) or JSON.parse(JSON.stringify(obj))
  optionalChain:null?.undefined throws, use ?.
  deleteReturn:delete returns boolean, not value
  iife:wrap in () for arrow function IIFE
  asyncLoop:forEach doesn't await
  asyncLoopFix:for...of with await, or Promise.all
  mapAsync:map returns promises, not results
  mapAsyncFix:await Promise.all(arr.map(fn))
|
@esGotchas |
  es5Strict:use strict required for modern patterns
  es5NoLetConst:ES5 has var only, use function scope
  es5NoArrow:ES5 has function() only, no =>
  es5NoTemplate:ES5 has string concat only
  es5NoClass:ES5 has prototype-based inheritance
  es5NoModule:ES5 has no import/export (use script tags)
  es5NoPromise:ES5 has no Promise (use callbacks)
  es6NoAsyncAwait:ES6 has Promise but no async/await (ES2017)
  es6NoRestSpread:ES6 has function rest params, not object rest/spread (ES2018)
  es6NoOptionalChain:ES6 has no ?. (ES2020)
  es6NoNullish:ES6 has no ?? (ES2020)
  es6NoPrivate:ES6 has no #private fields (ES2022)
  es6NoAtMethod:ES6 has no arr.at() (ES2022)
  transpile:use babel/polyfill or core-js for missing features
  browserslist:check targets in .browserslistrc or package.json
|
@patterns |
  debounce:fn that waits after last call
  throttle:fn that calls at most once per interval
  memoize:cache results by args
  curry:fn that returns fn until all args provided
  pipe:compose functions left to right
  compose:compose functions right to left
  maybe:null check chain
  guard:early return pattern
  sentinel:special value for "not found"
  factory:function that creates objects
  observer:pub/sub pattern
  strategy:algorithm selection pattern
  iterator:sequential access pattern
  proxy:intercept object operations
  observer2:new Proxy(target, handler)
|
@typeCoercion |
  string:" + 123 // "123
  number:+"" // 0, +"123" // 123
  boolean:!!0 // false, !!1 // true
  array:[1] // [1], [] // []
  object:Object(1) // {1}
  explicit:String(123), Number("123"), Boolean(0)
  implicit:5" - 3 // 2, "5" + 3 // "53
  NaN:+"hello" // NaN, NaN !== NaN
  isNaN:use Number.isNaN() not global isNaN
|
