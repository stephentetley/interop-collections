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
    /// Represents a Java Iterator.
    ///
    pub enum Collection[_a: Type, _r: Region](##java.util.Collection)


}

namespace Interop/Collections/Collection {

    use Interop/Collections.Collection;
    use Interop/Collections.Collection.{Collection};
    use Interop/Collections.Marshal;


    pub def getCollection(iter: Collection[a, r]): ##java.util.Collection = 
        let Collection(iter1) = iter;
        iter1

    pub def new(_: Region[r], iter: ##java.util.Collection): Collection[a, r] \ Write(r) = Collection(iter) as \Write(r)


    pub def iterator(r: Region[r1], c: Collection[a, r2]): Iterator[a, r1] \ { Read(r2), Write(r1) } with Marshal[a] =
        iteratorWith(r, Interop/Collections/Marshal.fromJavaObject, c)
        
    pub def iteratorWith(r: Region[r1], 
                            ocast: ##java.lang.Object -> a,
                            c: Collection[a, r2]): Iterator[a, r1] \ { Read(r2), Write(r1) } with Marshal[a] =
        import java.util.Collection.iterator(): ##java.util.Iterator & (r2 and r1) as iterator1;
        let Collection(c1) = c;
        Interop/Collections/RawIterator.new(r, iterator1(c1)) |> Interop/Collections/RawIterator.iteratorWith(ocast)

    /// pub def enumerator(r: Region[r1], c: Collection[a, r2]): Iterator[(a, Int32), r] \ { Read(r2), Write(r1) }  with Marshal[a] =
    ///     iterator(r, c) |> Iterator.enumerator

    pub def unfoldCollection(_: Region[r], f: s -> Option[(a, s)] & ef, st: s): Collection[a, r] \ { Write(r),  ef } with Marshal[a] =
        import new java.util.LinkedList(): ##java.util.LinkedList & r as new1;
        import java.util.LinkedList.add(##java.lang.Object): Bool & r as add1;
        def loop(st1, acc) = match f(st1) {
            case None         => Collection(acc as ##java.util.Collection)
            case Some(o, st2) => {discard add1(acc, Interop/Collections/Marshal.toJavaObject(o)); loop(st2, acc)}
        };
        loop(st, new1())


    pub def fromList(r: Region[r], l: List[a]): Collection[a, r] \ { Write(r) } with Marshal[a] =
        let step = xs -> match xs {
            case Nil     => None
            case x :: rs => Some((x, rs))
        };
        unfoldCollection(r, step, l)

}
