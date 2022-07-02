/*
 * Copyright 2022 Stephen Tetley
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

namespace Interop {

    ///
    /// Represents a ArrayList.
    ///
    pub enum RawMap[_k: Type, _v: Type, _r: Region](##java.util.Map)


}

namespace Interop/RawMap {

    use Interop.RawMap;
    use Interop.RawMap.{RawMap};
    use Interop.Marshal;
    use Interop.MarshalEnum;

    pub enum MapEntry[_k: Type, _v: Type,_: Region](##java.util.Map$Entry)


    pub def getMap(m: RawMap[k, v, r]): ##java.util.Map = 
        let RawMap(m1) = m;
        m1


    ///
    /// We don't need the inverse function `marshalMapEntry` because Java's API for building maps is `m.put(k, v)`
    /// so we never need to create a MapEntry.
    ///
    pub def unmarshalMapEntry(entry: MapEntry[k, v, r]): (k, v) \ Read(r) with Marshal[k], Marshal[v] =
        import java.util.Map$Entry.getKey(): ##java.lang.Object & r;
        import java.util.Map$Entry.getValue(): ##java.lang.Object & r;
        let MapEntry(entry1) = entry;
        let k = getKey(entry1);
        let v = getValue(entry1);                
        let k1 = Interop/Marshal.fromJavaObject(k);
        let v1 = Interop/Marshal.fromJavaObject(v);
        (k1, v1)


    pub def foldMap(f: (b, MapEntry[k, v, r]) -> b & ef, s: b, m: RawMap[k, v, r]): b \ { Read(r), ef} = 
        import java.util.Map.entrySet(): ##java.util.Set & r;
        import java.util.Set.iterator(): ##java.util.Iterator & r;
        import java.util.Iterator.hasNext(): Bool & r;
        import java.util.Iterator.next(): ##java.lang.Object & r;
        let set1 = entrySet(getMap(m));
        let iter = iterator(set1);
        def loop(ac) = {
            if (hasNext(iter)) {
                let entry = MapEntry(next(iter) as ##java.util.Map$Entry);
                let ac1 = f(ac, entry);
                loop(ac1)
            } else
                ac
        };
        loop(s)


    pub def unfoldViaHashMap(_: Region[r], f: s -> Option[(k, v, s)] & ef, st: s): RawMap[k, v, r] \ { Write(r), ef } with Marshal[k], Marshal[v] =
        import new java.util.HashMap(): ##java.util.HashMap & r as newHashMap;
        import java.util.HashMap.put(##java.lang.Object, ##java.lang.Object): ##java.lang.Object & r as put; 
        def loop(st1, ac) = match f(st1) {
            case None            => RawMap(ac as ##java.util.Map)
            case Some(k, v, st2) => { discard put(ac, Interop/Marshal.toJavaObject(k), Interop/Marshal.toJavaObject(v)); loop(st2, ac) }
        };
        loop(st, newHashMap())

    pub def fromMapViaHashMap(r: Region[r], m: Map[k, v]): RawMap[k, v, r] \ Write(r) with Marshal[k], Marshal[v] =
        let step = iter -> match Iterator.next(iter) {
            case Some(k, v)   => Some((k, v, iter))
            case None         => None
        };
        unfoldViaHashMap(r, step, Map.toIterator(r, m))

    pub def toMap(m: RawMap[k, v, r]): Map[k, v] \ { Read(r) } with Order[k], Marshal[k], Marshal[v] =
        let step = (acc, entry) -> {
            let (k, v) = unmarshalMapEntry(entry);
            Map.insert(k, v, acc)
        };
        foldMap(step, Map.empty(), m)

}
