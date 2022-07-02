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
    /// Represents a Java List.
    ///
    pub enum RawList[_a: Type, _r: Region](##java.util.List)


}

namespace Interop/RawList {

    use Interop.RawList;
    use Interop.RawList.{RawList};
    use Interop.Marshal;


    pub def getRawList(m: RawList[a, r]): ##java.util.List = 
        let RawList(m1) = m;
        m1


    ///
    /// Returns an iterator over `l`.
    ///
    pub def iterator(r1: Region[r1], l: RawList[a, r2]): Iterator[a, r1] \ { Read(r2), Read(r1) } with Marshal[a] =
        import java.util.List.iterator(): ##java.util.Iterator & (r2 and r1) as iterator1;
        let RawList(l1) = l;
        Interop/RawIterator.new(r1, iterator1(l1)) |> Interop/RawIterator.iterator


    pub def foldRawList(f: (b, a) -> b & ef, s: b, l: RawList[a, r]): b \ { Read(r), ef } with Marshal[a] =
        region r1 {
            let iter = iterator(r1, l);
            Iterator.foldLeft(f, s, iter)
        }


    pub def unfoldViaArrayList(_: Region[r], f: s -> Option[(a, s)] & ef, st: s): RawList[a, r] \ { Write(r),  ef } with Marshal[a] =
        import new java.util.ArrayList(): ##java.util.ArrayList & r as new1;
        import java.util.ArrayList.add(##java.lang.Object): Bool & r as add1;
        def loop(st1, acc) = match f(st1) {
            case None         => RawList(acc as ##java.util.List)
            case Some(o, st2) => {discard add1(acc, Interop/Marshal.toJavaObject(o)); loop(st2, acc)}
        };
        loop(st, new1())



}
