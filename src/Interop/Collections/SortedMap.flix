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

namespace Interop/Collections {

    ///
    /// Represents a Java SortedMap.
    ///
    pub enum SortedMap[_k: Type, _v: Type, _r: Region](##java.util.SortedMap)


}

namespace Interop/Collections/SortedMap {

    use Interop/Collections.SortedMap;
    use Interop/Collections.SortedMap.{SortedMap};
    use Interop/Collections/RawMap.MapEntry;
    use Interop/Collections/RawMap.MapEntry.{MapEntry};
    use Interop/Collections.Marshal;


    pub def getSortedMap(m: SortedMap[k, v, r]): ##java.util.SortedMap = 
        let SortedMap(m1) = m;
        m1

    pub def new(_: Region[r], prim: ##java.util.SortedMap): SortedMap[k, v, r] = SortedMap(prim)

    pub def getRegionOf(_: SortedMap[k, v, r]): Region[r] = () as Region[r]


    pub def foldMap(f: (b, (k, v)) -> b & ef, s: b, m: SortedMap[k, v, r]): b \ { Read(r), ef} with Order[k], Marshal[k], Marshal[v] = 
        region r1 {
            let iter = iterator(r1, m);
            Iterator.foldLeft(f, s, iter)
        }
        


    pub def unfoldViaTreeMap(_: Region[r], f: s -> Option[(k, v, s)] & ef, st: s): SortedMap[k, v, r] \ { Write(r), ef } with Marshal[k], Marshal[v] =
        import new java.util.TreeMap(): ##java.util.TreeMap & r as newTreeMap;
        import java.util.TreeMap.put(##java.lang.Object, ##java.lang.Object): ##java.lang.Object & r as put; 
        def loop(st1, ac) = match f(st1) {
            case None            => SortedMap(ac as ##java.util.SortedMap)
            case Some(k, v, st2) => { discard put(ac, Interop/Collections/Marshal.toJavaObject(k), Interop/Collections/Marshal.toJavaObject(v)); loop(st2, ac) }
        };
        loop(st, newTreeMap())

    pub def fromMapViaTreeMap(r: Region[r], m: Map[k, v]): SortedMap[k, v, r] \ Write(r) with Marshal[k], Marshal[v] =
        let step = iter -> match Iterator.next(iter) {
            case Some(k, v)   => Some((k, v, iter))
            case None         => None
        };
        unfoldViaTreeMap(r, step, Map.iterator(r, m))

    pub def toMap(m: SortedMap[k, v, r]): Map[k, v] \ { Read(r) } with Order[k], Marshal[k], Marshal[v] =
        let step = (acc, entry) -> {
            let (k, v) = entry;
            Map.insert(k, v, acc)
        };
        foldMap(step, Map.empty(), m)

    ///
    /// Returns an iterator over all key-value pairs in `m`.
    ///
    pub def iterator(r1: Region[r1], 
                        m: SortedMap[k, v, r2]): Iterator[(k, v), r1] \ { Read(r2), Write(r1) } with Order[k], Marshal[k], Marshal[v] =
        iteratorWith(r1, Interop/Collections/Marshal.fromJavaObject, Interop/Collections/Marshal.fromJavaObject, m)
    ///
    /// Returns an iterator over all key-value pairs in `m`.
    /// Can't use RawIterator because no Marshal instance for MapEntry
    ///
    pub def iteratorWith(_r1: Region[r1],
                            kcast: ##java.lang.Object -> k, 
                            vcast: ##java.lang.Object -> v,  
                            m: SortedMap[k, v, r2]): Iterator[(k, v), r1] \ { Read(r2), Write(r1) } with Order[k], Marshal[k], Marshal[v] =
        import java.util.SortedMap.entrySet(): ##java.util.Set & r2;
        import java.util.Set.iterator(): ##java.util.Iterator & (r2 and r1);
        import java.util.Iterator.hasNext(): Bool & r1;
        import java.util.Iterator.next(): ##java.lang.Object & r1;
        let set1 = entrySet(getSortedMap(m));
        let iter = iterator(set1);
        let isDone = () -> { 
            let ans = hasNext(iter);
            not ans
        };
        let getNext = () -> {
            let o = next(iter);
            Interop/Collections/RawMap.unmarshalMapEntryWith(kcast, vcast, MapEntry(o as ##java.util.Map$Entry))
        };
        Iterator(isDone, getNext)


    pub def fromListViaHashMap(r: Region[r], l: List[(k, v)]): SortedMap[k, v, r] \ Write(r) with Marshal[k], Marshal[v] =
        let step = xs -> match xs {
            case kv :: rs => let (k,v) = kv; Some((k, v, rs))
            case Nil      => None
        };
        unfoldViaTreeMap(r, step, l)
    
    pub def toList(m: SortedMap[k, v, r]): List[(k, v)] \ { Read(r) } with Order[k], Marshal[k], Marshal[v] =
        let step = (k, entry) -> ks -> k(entry :: ks);
        foldMap(step, ks -> ks, m) |> f -> f(Nil)

}
