@test
def test01(): Unit & Impure = 
    import static java.lang.System.getenv(): ##java.util.Map & Impure;
    use CollectionInterop.RawMap;
    use CollectionInterop.RawMap.{RawMap};
    let raw: RawMap[String, String, Static] = RawMap(getenv());
    let flixm = CollectionInterop/RawMap.toMap(raw);
    Map.foreach((k, v) -> println("${k} => ${v}"), flixm);
    ()
    