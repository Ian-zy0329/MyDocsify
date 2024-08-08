# map遍历方式
HashMap 遍历方式大致可以分为以下 4 类：
- 迭代器（Iterator）方式遍历；
- For Each 方式遍历；
- Lambda 表达式遍历（JDK 1.8+）;
- Streams API 遍历（JDK 1.8+）。

细分的话有以下七种
## 1.迭代器 EntrySet
        
        Map<Integer, String> map = new HashMap();
        Iterator<Map.Entry<Integer, String>> iterator = map.entrySet().iterator();
        while (iterator.hasNext()) {
            Map.Entry<Integer, String> entry = iterator.next();
            System.out.println(entry.getKey());
            System.out.println(entry.getValue());
        }
## 2.迭代器 KeySet

        Map<Integer, String> map = new HashMap();
        Iterator<Integer> iterator = map.keySet().iterator();
        while (iterator.hasNext()) {
            Integer key = iterator.next();
            System.out.println(key);
            System.out.println(map.get(key));
        }
## 3.ForEach EntrySet

        Map<Integer, String> map = new HashMap();
        for (Map.Entry<Integer, String> entry : map.entrySet()) {
            System.out.println(entry.getKey());
            System.out.println(entry.getValue());
        }
## 4.ForEach KeySet

        Map<Integer, String> map = new HashMap();
        for (Integer key : map.keySet()) {
            System.out.println(key);
            System.out.println(map.get(key));
        }
## 5.Lambda

        Map<Integer, String> map = new HashMap();
        map.forEach((key, value) -> {
            System.out.println(key);
            System.out.println(value);
        });
## 6.Streams API 单线程
        
        Map<Integer, String> map = new HashMap();
        map.entrySet().stream().forEach((entry) -> {
            System.out.println(entry.getKey());
            System.out.println(entry.getValue());
        });

## 7.Streams API 多线程

        Map<Integer, String> map = new HashMap();
        map.entrySet().parallelStream().forEach((entry) -> {
            System.out.println(entry.getKey());
            System.out.println(entry.getValue());
        });