public static class Helper
{
  public static Object perform(Object object, String method, Class<?>[] types, Object[] arguments) throws Exception
  {
    return object.getClass().getMethod(method, types).invoke(object, arguments);
  }
  
  public static Object performClass(Class<?> type, String method, Class<?>[] types, Object[] arguments) throws Exception
  {
    return type.getMethod(method, types).invoke(null, arguments);
  }
  
  public static <T> T construct(Class<T> type, Class<?>[] types, Object[] arguments) throws Exception
  {
    return type.getConstructor(types).newInstance(arguments);
  }    
}
