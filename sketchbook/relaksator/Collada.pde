import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Map;
import java.util.HashMap;
import papaya.Mat;

public static abstract class ColladaPart
{
  protected PApplet pApplet = null;
  
  private static Map<String, ColladaPart> idMap = new HashMap<String, ColladaPart>();
  
  protected ColladaPart(PApplet pApplet, XML element)
  {
    this.pApplet = pApplet;
    
    String id = null;

    if((id = element.getString("id")) != null)
    {
      idMap.put(id, this); 
    }        
  }
  
  public <T> T parseChild(XML parent, String childName, Class<T> type) throws Exception
  {
    XML child = parent.getChild(childName);
    if(child != null)
    {
      return Helper.construct(type, new Class<?>[] {PApplet.class, XML.class}, new Object[] {pApplet, child});
    }
    else
    {
      return null;
    }
  }
  
  public <T> void parseChildren(XML parent, String childName, Class<T> type, Collection<T> collection) throws Exception
  {
    for(XML child : parent.getChildren(childName))
    {
      collection.add(Helper.construct(type, new Class<?>[] {PApplet.class, XML.class}, new Object[] {pApplet, child}));
    }    
  }
  
  public <T> T parseAttribute(XML parent, String attributeName, Class<T> type) throws Exception
  {
    return parseAttribute(parent, attributeName, type, null);
  }
  
  
  public <T> T parseAttribute(XML parent, String attributeName, Class<T> type, T def) throws Exception
  {
    String attribute = parent.getString(attributeName);
    if(attribute != null)
    {
      return Helper.construct(type, new Class<?>[] {String.class}, new Object[] {attribute});
    }
    else
    {
      return def;
    }
  }
  
  public static <T> T getById(String id, Class<T> type)
  {
    return (T)idMap.get(id);
  }
  
  public static Class<?> classById(String id)
  {
    return idMap.get(id).getClass();
  }

  public static <T> T getByURL(String url, Class<T> type)
  {
    return (T)idMap.get(url.substring(1));
  }
  
  public static Class<?> classByURL(String url)
  {
    return idMap.get(url.substring(1)).getClass();
  }
  
}

public static abstract class ColladaLibrary extends ColladaPart
{
  public ColladaLibrary(PApplet pApplet, XML library) throws Exception
  {
    super(pApplet, library);
  }
}


/* Animation */

public static class ColladaAnimation extends ColladaPart
{
  protected String id = null;
  protected String name = null;
  
  protected ColladaAsset asset = null;
  protected List<ColladaAnimation> animationList = new ArrayList<ColladaAnimation>();
  protected List<ColladaSource> sourceList = new ArrayList<ColladaSource>();
  protected List<ColladaSampler> samplerList = new ArrayList<ColladaSampler>();
  protected List<ColladaChannel> channelList = new ArrayList<ColladaChannel>();
  protected List<ColladaExtra> extraList = new ArrayList<ColladaExtra>();
  
  public ColladaAnimation(PApplet pApplet, XML animation) throws Exception
  {
    super(pApplet, animation);
    
    id = parseAttribute(animation, "id", String.class);
    name = parseAttribute(animation, "name", String.class);
    
    asset = parseChild(animation, "asset", ColladaAsset.class);
    parseChildren(animation, "animation", ColladaAnimation.class, animationList);
    parseChildren(animation, "source", ColladaSource.class, sourceList);
    parseChildren(animation, "sampler", ColladaSampler.class, samplerList);
    parseChildren(animation, "channel", ColladaChannel.class, channelList);
    parseChildren(animation, "extra", ColladaExtra.class, extraList);
  }
}

public static class ColladaAnimationClip extends ColladaPart
{
  public ColladaAnimationClip(PApplet pApplet, XML animationClip) throws Exception
  {
    super(pApplet, animationClip);
    PApplet.println("TODO ColladaAnimationClip");
  }
}

public static class ColladaChannel extends ColladaPart
{
  protected String source = null;
  protected String target = null;
  
  public ColladaChannel(PApplet pApplet, XML channel) throws Exception
  {
    super(pApplet, channel);
    
    source = parseAttribute(channel, "source", String.class);
    target = parseAttribute(channel, "target", String.class);
  }
}

public static class ColladaInstanceAnimation extends ColladaPart
{
  public ColladaInstanceAnimation(PApplet pApplet, XML instanceAnimation) throws Exception
  {
    super(pApplet, instanceAnimation);
    PApplet.println("TODO ColladaInstanceAnimation");
  }
}

public static class ColladaLibraryAnimationClips extends ColladaLibrary
{
  public ColladaLibraryAnimationClips(PApplet pApplet, XML libraryAnimationClips) throws Exception
  {
    super(pApplet, libraryAnimationClips);
    PApplet.println("TODO ColladaLibraryAnimationClips");
  }
}

public static class ColladaLibraryAnimations extends ColladaLibrary
{
  protected String id = null;
  protected String name = null;
  
  protected ColladaAsset asset = null;
  protected List<ColladaAnimation> animationList = new ArrayList<ColladaAnimation>();
  protected List<ColladaExtra> extraList = new ArrayList<ColladaExtra>();
  
  public ColladaLibraryAnimations(PApplet pApplet, XML libraryAnimations) throws Exception
  {
    super(pApplet, libraryAnimations);
    
    id = parseAttribute(libraryAnimations, "id", String.class);
    name = parseAttribute(libraryAnimations, "name", String.class);
 
    asset = parseChild(libraryAnimations, "asset", ColladaAsset.class);
    parseChildren(libraryAnimations, "animation", ColladaAnimation.class, animationList);
    parseChildren(libraryAnimations, "extra", ColladaExtra.class, extraList);
  }
}

public static class ColladaSampler extends ColladaPart
{
  protected String id = null;
  
  protected List<ColladaInput> inputList = new ArrayList<ColladaInput>();
  
  public ColladaSampler(PApplet pApplet, XML sampler) throws Exception
  {
    super(pApplet, sampler);
    
    id = parseAttribute(sampler, "id", String.class);
    
    parseChildren(sampler, "input", ColladaInput.class, inputList);
  }
}

/* Camera */

public static class ColladaCamera extends ColladaPart
{
  public ColladaCamera(PApplet pApplet, XML camera) throws Exception
  {
    super(pApplet, camera);
    PApplet.println("TODO ColladaCamera");
  }
}

public static class ColladaImager extends ColladaPart
{
  public ColladaImager(PApplet pApplet, XML imager) throws Exception
  {
    super(pApplet, imager);
    PApplet.println("TODO ColladaImager");
  }
}

public static class ColladaInstanceCamera extends ColladaPart
{
  public ColladaInstanceCamera(PApplet pApplet, XML instanceCamera) throws Exception
  {
    super(pApplet, instanceCamera);
    PApplet.println("TODO ColladaInstanceCamera");
  }
}

public static class ColladaLibraryCameras extends ColladaLibrary
{
  public ColladaLibraryCameras(PApplet pApplet, XML libraryCameras) throws Exception
  {
    super(pApplet, libraryCameras);
    PApplet.println("TODO ColladaLibraryCameras");
  }
}

public static class ColladaOptics extends ColladaPart
{
  public ColladaOptics(PApplet pApplet, XML optics) throws Exception
  {
    super(pApplet, optics);
    PApplet.println("TODO ColladaOptics");
  }
}

public static class ColladaOrthographic extends ColladaPart
{
  public ColladaOrthographic(PApplet pApplet, XML orthographic) throws Exception
  {
    super(pApplet, orthographic);
    PApplet.println("TODO ColladaOrthographic");
  }
}

public static class ColladaPerspective extends ColladaPart
{
  public ColladaPerspective(PApplet pApplet, XML perspective) throws Exception
  {
    super(pApplet, perspective);
    PApplet.println("TODO ColladaPerspective");
  }
}
/* Controller */

public static class ColladaBindShapeMatrix extends ColladaPart
{
  protected float[][] content = new float[4][4];
  
  public ColladaBindShapeMatrix(PApplet pApplet, XML bindShapeMatrix) throws Exception
  {
    super(pApplet, bindShapeMatrix);
    
    Integer i = 0;
    Integer j = 0;
    for(String value : bindShapeMatrix.getContent().split("\\s+"))
    {
      if(value.length() > 0)
      {
        content[i][j] = Float.valueOf(value);
        if(++i >= 4)
        {
          i = 0;
          ++j;
        }
      }
    }
  }
}

public static class ColladaController extends ColladaPart
{
  protected String id = null;
  protected String name = null;
 
  protected ColladaAsset asset = null;
  protected ColladaSkin skin = null;
  protected ColladaMorph morph = null;
  protected List<ColladaExtra> extraList = new ArrayList<ColladaExtra>(); 
  
  public ColladaController(PApplet pApplet, XML controller) throws Exception
  {
    super(pApplet, controller);
    
    id = parseAttribute(controller, "id", String.class);
    name = parseAttribute(controller, "name", String.class);
    
    asset = parseChild(controller, "asset", ColladaAsset.class);
    skin = parseChild(controller, "skin", ColladaSkin.class);
    morph = parseChild(controller, "morph", ColladaMorph.class);
    parseChildren(controller, "extra", ColladaExtra.class, extraList);
  }
}

public static class ColladaInstanceController extends ColladaPart
{
  protected String sid = null;
  protected String name = null;
  protected String url = null;
  
  protected List<ColladaSkeleton> skeletonList = new ArrayList<ColladaSkeleton>();
  //protected ColladaBindMaterial bindMaterial = null;
  protected List<ColladaExtra> extraList = new ArrayList<ColladaExtra>();
  
  public ColladaInstanceController(PApplet pApplet, XML instanceController) throws Exception
  {
    super(pApplet, instanceController);
    
    sid = parseAttribute(instanceController, "sid", String.class);
    name = parseAttribute(instanceController, "name", String.class);
    url = parseAttribute(instanceController, "url", String.class);
    
    parseChildren(instanceController, "skeleton", ColladaSkeleton.class, skeletonList);
    //bindMaterial = parseChild(instanceController, "bind_material", ColladaBindMaterial.class);
    parseChildren(instanceController, "extra", ColladaExtra.class, extraList); 
  }
}

public static class ColladaJoints extends ColladaPart
{
  protected List<ColladaInput> inputList = new ArrayList<ColladaInput>();
  protected List<ColladaExtra> extraList = new ArrayList<ColladaExtra>();
  
  public ColladaJoints(PApplet pApplet, XML joints) throws Exception
  {
    super(pApplet, joints);
    
    parseChildren(joints, "input", ColladaInput.class, inputList);
    parseChildren(joints, "extra", ColladaExtra.class, extraList);
  }
}

public static class ColladaLibraryControllers extends ColladaLibrary
{
  protected String id = null;
  protected String name = null;
  
  protected ColladaAsset asset = null;
  protected List<ColladaController> controllerList = new ArrayList<ColladaController>();
  protected List<ColladaExtra> extraList = new ArrayList<ColladaExtra>();
  
  public ColladaLibraryControllers(PApplet pApplet, XML libraryControllers) throws Exception
  {
    super(pApplet, libraryControllers);
    
    id = parseAttribute(libraryControllers, "id", String.class);
    name = parseAttribute(libraryControllers, "name", String.class);
    
    asset = parseChild(libraryControllers, "asset", ColladaAsset.class);
    parseChildren(libraryControllers, "controller", ColladaController.class, controllerList);
    parseChildren(libraryControllers, "extra", ColladaExtra.class, extraList);
  }
}

public static class ColladaMorph extends ColladaPart
{
  public ColladaMorph(PApplet pApplet, XML morph) throws Exception
  {
    super(pApplet, morph);
    PApplet.println("TODO ColladaMorph");
  }
}

public static class ColladaSkeleton extends ColladaPart
{
  public ColladaSkeleton(PApplet pApplet, XML skeleton) throws Exception
  {
    super(pApplet, skeleton);
    PApplet.println("TODO ColladaSkeleton");
  }
}

public static class ColladaSkin extends ColladaPart
{
  protected String sourceAttr = null;
  
  protected ColladaBindShapeMatrix bindShapeMatrix = null;
  protected List<ColladaSource> sourceList = new ArrayList<ColladaSource>();
  protected ColladaJoints joints = null;
  protected ColladaVertexWeights vertexWeights = null;
  protected List<ColladaExtra> extraList = new ArrayList<ColladaExtra>();
  
  public ColladaSkin(PApplet pApplet, XML skin) throws Exception
  {
    super(pApplet, skin);
    
    sourceAttr = parseAttribute(skin, "source", String.class);
    
    bindShapeMatrix = parseChild(skin, "bind_shape_matrix", ColladaBindShapeMatrix.class);
    parseChildren(skin, "source", ColladaSource.class, sourceList);
    joints = parseChild(skin, "joints", ColladaJoints.class);
    vertexWeights = parseChild(skin, "vertex_weights", ColladaVertexWeights.class);
    parseChildren(skin, "extra", ColladaExtra.class, extraList);
  }
}

public static class ColladaTargets extends ColladaPart
{
  public ColladaTargets(PApplet pApplet, XML targets) throws Exception
  {
    super(pApplet, targets);
    PApplet.println("TODO ColladaTargets");
  }
}

public static class ColladaV extends ColladaPart
{
  protected List<Integer> content = new ArrayList<Integer>();
  
  public ColladaV(PApplet pApplet, XML v) throws Exception
  {
    super(pApplet, v);

    for(String value : v.getContent().split("\\s+"))
    {
      if(value.length() > 0)
      {
        content.add(Integer.valueOf(value));
      }  
    }
  }
}

public static class ColladaVCount extends ColladaPart
{
  protected List<Integer> content = new ArrayList<Integer>();  
  
  public ColladaVCount(PApplet pApplet, XML vCount) throws Exception
  {
    super(pApplet, vCount);
    
    for(String value : vCount.getContent().split("\\s+"))
    {
      if(value.length() > 0)
      {
        content.add(Integer.valueOf(value));
      }  
    }
  }
}

public static class ColladaVertexWeights extends ColladaPart
{
  protected Integer count = null;
  
  protected List<ColladaInput> inputList = new ArrayList<ColladaInput>();
  protected ColladaVCount vCount = null;
  protected ColladaV v = null;
  protected List<ColladaExtra> extraList = new ArrayList<ColladaExtra>();
  
  public ColladaVertexWeights(PApplet pApplet, XML vertexWeights) throws Exception
  {
    super(pApplet, vertexWeights);
    
    count = parseAttribute(vertexWeights, "count", Integer.class);
    
    parseChildren(vertexWeights, "input", ColladaInput.class, inputList);
    vCount = parseChild(vertexWeights, "vcount", ColladaVCount.class);
    v = parseChild(vertexWeights, "v", ColladaV.class);
    parseChildren(vertexWeights, "extra", ColladaExtra.class, extraList);
  }
}
 
/* Data Flow */

public static class ColladaAccessor extends ColladaPart
{
  protected Integer count = null;
  protected Integer offset = null;
  protected String source = null;
  protected Integer stride = null;
  
  protected List<ColladaParam> paramList = new ArrayList<ColladaParam>();
  
  public ColladaAccessor(PApplet pApplet, XML accessor) throws Exception
  {
    super(pApplet, accessor);
    
    count = parseAttribute(accessor, "count", Integer.class);
    offset = parseAttribute(accessor, "offset", Integer.class, 0);
    source = parseAttribute(accessor, "source", String.class);
    stride = parseAttribute(accessor, "stride", Integer.class, 1);
    
    parseChildren(accessor, "param", ColladaParam.class, paramList);
  }
  
  public Integer getCount()
  {
    return count;
  }
  
  public Map<String, Object> get(Integer index) throws Exception
  {
    if(index >= count)
    {
      throw new IndexOutOfBoundsException("Indeks dla akcesora wykracza poza zakres.");
    }
    
    Map<String, Object> map = new HashMap<String, Object>();
    List<Object> list = getByURL(source, ColladaArray.class).getContent().subList(offset + index*stride, offset+(index+1)*stride);
    for(Integer i = 0; i < paramList.size(); ++i)
    {
      ColladaParam param = paramList.get(i);
      if(param.getName() == null)
      {
        continue;
      }
      Object object = list.get(i);
      
      Class<?> sourceClass = object.getClass();
      Class<?> destinationClass = param.getParamClass();
     
      if(sourceClass == destinationClass)
      {
       map.put(param.getName(),object);       
      }
      else if(Number.class.isAssignableFrom(sourceClass) && Number.class.isAssignableFrom(destinationClass))
      {
        Number num = (Number) object;
        if(destinationClass == Byte.class)
        {
          map.put(param.getName(),new Byte(num.byteValue()));
        } 
        else if(destinationClass == Short.class)
        { 
          map.put(param.getName(),new Short(num.shortValue()));
        } 
        else if(destinationClass == Integer.class)
        {
          map.put(param.getName(),new Integer(num.intValue())); 
        } 
        else if(destinationClass == Long.class)
        { 
         map.put(param.getName(),new Long(num.longValue()));
        } 
        else if(destinationClass == Float.class)
        { 
          map.put(param.getName(),new Float(num.floatValue()));
        } 
        else if(destinationClass == Double.class)
        { 
          map.put(param.getName(),new Double(num.doubleValue()));
        }       
        else
        {
          map.put(param.getName(),Helper.performClass(destinationClass, "valueOf", new Class<?>[] {(Class<?>)sourceClass.getField("TYPE").get(null)}, new Object[] {object}));          
        }
     }
     else if(sourceClass == Boolean.class)
     {
       map.put(param.getName(),Helper.performClass(destinationClass, "valueOf", new Class<?>[] {(Class<?>)sourceClass.getField("TYPE").get(null)}, new Object[] {object}));        
     }
     else
     {
       map.put(param.getName(),Helper.performClass(destinationClass, "valueOf", new Class<?>[] {sourceClass}, new Object[] {object}));
     }
    }
    
    return map;  
  }
}

public static abstract class ColladaArray<T> extends ColladaPart
{
  protected Integer count = null;
  protected String id = null;
  protected String name = null;
  
  protected List<T> content = new ArrayList<T>();
  
  public ColladaArray(PApplet pApplet, XML array, Class<T> type, T empty) throws Exception
  {
    super(pApplet, array);
    
    count = parseAttribute(array, "count", Integer.class);
    id = parseAttribute(array, "id", String.class);
    name = parseAttribute(array, "name", String.class);
    
    
    for(String value : array.getContent().split("\\s+"))
    {
      if(value.length() > 0)
      {
        content.add((T)Helper.construct(type,new Class<?>[] { String.class }, new Object[] { value }));
      }  
    }
    
    if(content.size() > count)
    {
      pApplet.println("WARNING! Array with id "+String.valueOf(id)+" needs to shrink.");
      content = content.subList(0, count);
    }
    else if(content.size() < count)
    {
      pApplet.println("WARNING! Array with id "+String.valueOf(id)+" needs to grow.");
      content.addAll(Collections.nCopies(count - content.size(),empty));
    }
  }
  
  public List<T> getContent()
  {
    return content;
  } 
}

public static class ColladaBoolArray extends ColladaArray<Boolean>
{
  public ColladaBoolArray(PApplet pApplet, XML boolArray) throws Exception
  {
    super(pApplet, boolArray, Boolean.class, false);
  }
}

public static class ColladaFloatArray extends ColladaArray<Float>
{
  protected Integer digits = null;
  protected Integer magnitude = null;
  
  public ColladaFloatArray(PApplet pApplet, XML floatArray) throws Exception
  {
    super(pApplet, floatArray, Float.class, 0.0);
    
    digits = parseAttribute(floatArray, "digits", Integer.class, 6);
    magnitude = parseAttribute(floatArray, "magnitude", Integer.class, 38);    
  }
}

public static class ColladaIDREFArray extends ColladaArray<String>
{  
  public ColladaIDREFArray(PApplet pApplet, XML idrefArray) throws Exception
  {
    super(pApplet, idrefArray, String.class,"");    
  }
}

public static class ColladaIntArray extends ColladaArray<Integer>
{
  protected Integer minInclusive = null;
  protected Integer maxInclusive = null;
    
  public ColladaIntArray(PApplet pApplet, XML intArray) throws Exception
  {
    super(pApplet, intArray, Integer.class, 0);
    
    minInclusive = parseAttribute(intArray, "minInclusive", Integer.class, -2147483648);
    maxInclusive = parseAttribute(intArray, "maxInclusive", Integer.class, 2147483647);       
  }
}

public static class ColladaNameArray extends ColladaArray<String>
{   
  public ColladaNameArray(PApplet pApplet, XML nameArray) throws Exception
  {
    super(pApplet, nameArray, String.class, "");
  }
}

public static class ColladaParam extends ColladaPart
{
  protected String name = null;
  protected String sid = null;
  protected String type = null;
  protected String semantic = null;
  
  public ColladaParam(PApplet pApplet, XML param) throws Exception
  {
    super(pApplet, param);
    
    name = parseAttribute(param, "name", String.class);
    sid = parseAttribute(param, "sid", String.class);
    type = parseAttribute(param, "type", String.class);
    semantic = parseAttribute(param, "semantic", String.class);
  }
  
  public String getName()
  {
    return name;
  }
  
  public Class<?> getParamClass()
  {
    if(type.equals("bool"))
    {
      return Boolean.class;
    }
    else if(type.equals("short"))
    {
      return Short.class;
    }    
    else if(type.equals("int"))
    {
      return Integer.class;
    }
    else if(type.equals("long"))
    {
      return Long.class;
    }    
    else if(type.equals("float"))
    {
      return Float.class;
    }
    else if(type.equals("double"))
    {
      return Double.class;
    }
    else if(type.equals("Name"))
    {
      return String.class;
    }
    else if(type.equals("IDREF"))
    {
      return String.class;
    }
    else
    {
      return String.class;
    }
  }
}

public static class ColladaSource extends ColladaPart
{
  protected String id = null;
  protected String name = null;
  
  protected ColladaAsset asset = null;
  protected ColladaIDREFArray idrefArray = null;
  protected ColladaNameArray nameArray = null;
  protected ColladaBoolArray boolArray = null;
  protected ColladaFloatArray floatArray = null;
  protected ColladaIntArray intArray = null;
  protected ColladaTechniqueCommonInSource techniqueCommon = null;
  protected List<ColladaTechnique> colladaTechniqueList = new ArrayList<ColladaTechnique>();
  
  public ColladaSource(PApplet pApplet, XML source) throws Exception
  {
    super(pApplet, source);
    
    id = parseAttribute(source, "id", String.class);
    name = parseAttribute(source, "name", String.class);
    
    asset = parseChild(source, "asset", ColladaAsset.class);
    idrefArray = parseChild(source, "IDREF_array", ColladaIDREFArray.class);
    nameArray = parseChild(source, "Name_array", ColladaNameArray.class);
    boolArray = parseChild(source, "bool_array", ColladaBoolArray.class);
    floatArray = parseChild(source, "float_array", ColladaFloatArray.class);
    intArray = parseChild(source, "int_array", ColladaIntArray.class);
    techniqueCommon = parseChild(source, "technique_common", ColladaTechniqueCommonInSource.class);
    parseChildren(source, "technique", ColladaTechnique.class, colladaTechniqueList);
  }
  
  public ColladaAbstractTechnique getTechnique()
  {
    return techniqueCommon;
  }
  
  public Map<String, Object> getUsingTechnique(Integer index) throws Exception
  {
    return ((ColladaTechniqueCommonInSource)this.getTechnique()).getUsingAccessor(index);
  }
}

public static class ColladaInput extends ColladaPart
{
  protected Integer offset = null;
  protected String semantic = null;
  protected String source = null;
  protected Integer set = null;
  
  public ColladaInput(PApplet pApplet, XML input) throws Exception
  {
    super(pApplet, input);
    
    offset = parseAttribute(input, "offset", Integer.class);
    semantic = parseAttribute(input, "semantic", String.class);
    source = parseAttribute(input, "source", String.class);
    set = parseAttribute(input, "set", Integer.class);
  }
  
  public Map<String, Map<String, Object>> getUsingInput(Integer index) throws Exception
  {
    Class<?> type = classByURL(source);
    if(type == ColladaSource.class)
    {
      Map<String, Map<String, Object>> map = new HashMap<String, Map<String, Object>>();
      map.put(semantic,getByURL(source, ColladaSource.class).getUsingTechnique(index));
      return map;
    }
    else if(type == ColladaVertices.class)
    {
      return getByURL(source, ColladaVertices.class).getUsingVertices(index);
    }
    else
    {
      return null;
    }
  }
  
  public Integer getOffset()
  {
    return offset;
  }
  
  public String getSemantic()
  {
    return semantic;
  }
}

/* Extensibility */

public static class ColladaExtra extends ColladaPart
{
  protected String id = null;
  protected String name = null;
  protected String type = null;
 
  protected ColladaAsset asset = null;
  protected List<ColladaTechnique> techniqueList = new ArrayList<ColladaTechnique>();
 
  public ColladaExtra(PApplet pApplet, XML extra) throws Exception
  {
    super(pApplet, extra);
    id = parseAttribute(extra, "id", String.class);
    name = parseAttribute(extra, "name", String.class);
    type = parseAttribute(extra, "type", String.class);
    
    asset = parseChild(extra, "asset", ColladaAsset.class);
    parseChildren(extra, "technique", ColladaTechnique.class, techniqueList);
  }
}

public static abstract class ColladaAbstractTechnique extends ColladaPart
{
  public ColladaAbstractTechnique(PApplet pApplet, XML abstractTechnique) throws Exception
  {
    super(pApplet, abstractTechnique);
  }
}

public static class ColladaTechnique extends ColladaAbstractTechnique
{
  protected String profile = null;
  protected String xmlns = null;  
  
  public ColladaTechnique(PApplet pApplet, XML technique) throws Exception
  {
    super(pApplet, technique);
    profile = parseAttribute(technique, "profile", String.class);
    xmlns = parseAttribute(technique, "xmlns", String.class);
  }
}

public static class ColladaTechniqueCommon extends ColladaAbstractTechnique
{
  public ColladaTechniqueCommon(PApplet pApplet, XML techniqueCommon) throws Exception
  {
    super(pApplet, techniqueCommon);
  }
}

public static class ColladaTechniqueCommonInBindMaterial extends ColladaTechniqueCommon 
{
  public ColladaTechniqueCommonInBindMaterial(PApplet pApplet, XML techniqueCommonInBindMaterial) throws Exception
  {
    super(pApplet, techniqueCommonInBindMaterial);
    PApplet.println("TODO ColladaTechniqueCommonInBindMaterial");
  }
}

public static class ColladaTechniqueCommonInInstanceRigidBody extends ColladaTechniqueCommon 
{
  public ColladaTechniqueCommonInInstanceRigidBody(PApplet pApplet, XML techniqueCommonInInstanceRigidBody) throws Exception
  {
    super(pApplet, techniqueCommonInInstanceRigidBody);
    PApplet.println("TODO ColladaTechniqueCommonInInstanceRigidBody");
  }
}

public static class ColladaTechniqueCommonInLight extends ColladaTechniqueCommon 
{
  public ColladaTechniqueCommonInLight(PApplet pApplet, XML techniqueCommonInLight) throws Exception
  {
    super(pApplet, techniqueCommonInLight);
    PApplet.println("TODO ColladaTechniqueCommonInLight");
  }
}

public static class ColladaTechniqueCommonInOptics extends ColladaTechniqueCommon 
{
  public ColladaTechniqueCommonInOptics(PApplet pApplet, XML techniqueCommonInOptics) throws Exception
  {
    super(pApplet, techniqueCommonInOptics);
    PApplet.println("TODO ColladaTechniqueCommonInOptics");
  }
}

public static class ColladaTechniqueCommonInPhysicsMaterial extends ColladaTechniqueCommon 
{
  public ColladaTechniqueCommonInPhysicsMaterial(PApplet pApplet, XML techniqueCommonInPhysicsMaterial) throws Exception
  {
    super(pApplet, techniqueCommonInPhysicsMaterial);
    PApplet.println("TODO ColladaTechniqueCommonInPhysicsMaterial");
  }
}

public static class ColladaTechniqueCommonInPhysicsScene extends ColladaTechniqueCommon 
{
  public ColladaTechniqueCommonInPhysicsScene(PApplet pApplet, XML techniqueCommonInPhysicsScene) throws Exception
  {
    super(pApplet, techniqueCommonInPhysicsScene);
    PApplet.println("TODO ColladaTechniqueCommonInPhysicsScene");
  }
}

public static class ColladaTechniqueCommonInRigidBody extends ColladaTechniqueCommon 
{
  public ColladaTechniqueCommonInRigidBody(PApplet pApplet, XML techniqueCommonInRigidBody) throws Exception
  {
    super(pApplet, techniqueCommonInRigidBody);
    PApplet.println("TODO ColladaTechniqueCommonInRigidBody");
  }
}

public static class ColladaTechniqueCommonInRigidConstraint extends ColladaTechniqueCommon 
{
  public ColladaTechniqueCommonInRigidConstraint(PApplet pApplet, XML techniqueCommonInRigidConstraint) throws Exception
  {
    super(pApplet, techniqueCommonInRigidConstraint);
    PApplet.println("TODO ColladaTechniqueCommonInRigidConstraint");
  }
}

public static class ColladaTechniqueCommonInSource extends ColladaTechniqueCommon 
{
  protected ColladaAccessor accessor = null;
  
  public ColladaTechniqueCommonInSource(PApplet pApplet, XML techniqueCommonInSource) throws Exception
  {
    super(pApplet, techniqueCommonInSource);
    
    accessor = parseChild(techniqueCommonInSource, "accessor", ColladaAccessor.class);
  }
  
  public ColladaAccessor getAccessor()
  {
    return accessor;
  }
  
  public Map<String, Object> getUsingAccessor(Integer index) throws Exception
  {
    return this.getAccessor().get(index);
  }
}

/* Geometry */

public static class ColladaControlVertices extends ColladaPart
{
  public ColladaControlVertices(PApplet pApplet, XML controlVertices) throws Exception
  {
    super(pApplet, controlVertices);
    PApplet.println("TODO ColladaControlVertices");
  }
}

public static class ColladaGeometry extends ColladaPart
{
  protected String id = null;
  protected String name = null;
  
  protected ColladaAsset asset = null;
  //protected ColladaConvexMesh convexMesh = null;
  protected ColladaMesh mesh = null;
  protected ColladaSpline spline = null;
  protected List<ColladaExtra> extraList = new ArrayList<ColladaExtra>();  
  
  public ColladaGeometry(PApplet pApplet, XML geometry) throws Exception
  {
    super(pApplet, geometry);
    
    id = parseAttribute(geometry, "id", String.class);
    name = parseAttribute(geometry, "name", String.class);
    
    asset = parseChild(geometry, "asset", ColladaAsset.class);
    //convexMesh = parseChild(geometry, "convex_mesh", ColladaConvexMesh.class);
    mesh = parseChild(geometry, "mesh", ColladaMesh.class);
    spline = parseChild(geometry, "spline", ColladaSpline.class);
    parseChildren(geometry, "extra", ColladaExtra.class, extraList);
  }
  
  public void draw() throws Exception
  {
    if(mesh != null)
    {
      mesh.draw();
    }
  }
}

public static class ColladaInstanceGeometry extends ColladaPart
{
  protected String sid = null;
  protected String name = null;
  protected String url = null;  
  
  //protected ColladaBindMaterial bindMaterial = null;
  protected List<ColladaExtra> extraList = new ArrayList<ColladaExtra>();
  
  public ColladaInstanceGeometry(PApplet pApplet, XML instanceGeometry) throws Exception
  {
    super(pApplet, instanceGeometry);
    
    sid = parseAttribute(instanceGeometry,"sid",String.class);
    name = parseAttribute(instanceGeometry,"name",String.class);
    url = parseAttribute(instanceGeometry,"url",String.class);
    
    //bindMaterial = parseChild(instanceGeometry, "bind_material", ColladaBindMaterial.class);
    parseChildren(instanceGeometry, "extra", ColladaExtra.class, extraList);
  }
  
  public void draw() throws Exception
  {
    getByURL(url, ColladaGeometry.class).draw();
  }
}

public static class ColladaLibraryGeometries extends ColladaLibrary
{
  protected String id = null;
  protected String name = null;
  
  protected ColladaAsset asset = null;
  protected List<ColladaGeometry> geometryList = new ArrayList<ColladaGeometry>();
  protected List<ColladaExtra> extraList = new ArrayList<ColladaExtra>();
  
  public ColladaLibraryGeometries(PApplet pApplet, XML libraryGeometries) throws Exception
  {
    super(pApplet, libraryGeometries);
    
    id = parseAttribute(libraryGeometries, "id", String.class);
    name = parseAttribute(libraryGeometries, "name", String.class);
    
    asset = parseChild(libraryGeometries, "asset", ColladaAsset.class);
    parseChildren(libraryGeometries, "geometry", ColladaGeometry.class, geometryList);
    parseChildren(libraryGeometries, "extra", ColladaExtra.class, extraList);
  }
}

public static class ColladaLines extends ColladaPart
{
  public ColladaLines(PApplet pApplet, XML lines) throws Exception
  {
    super(pApplet, lines);
    PApplet.println("TODO ColladaLines");
  }
}

public static class ColladaLineStrips extends ColladaPart
{
  public ColladaLineStrips(PApplet pApplet, XML lineStrips) throws Exception
  {
    super(pApplet, lineStrips);
    PApplet.println("TODO ColladaLineStrips");
  }
}

public static class ColladaMesh extends ColladaPart
{
  protected List<ColladaSource> sourceList = new ArrayList<ColladaSource>();
  protected ColladaVertices vertices = null;
  protected List<ColladaLines> linesList = new ArrayList<ColladaLines>();
  protected List<ColladaLineStrips> lineStripsList = new ArrayList<ColladaLineStrips>();
  protected List<ColladaPolygons> polygonsList = new ArrayList<ColladaPolygons>();
  protected List<ColladaPolyList> polyListList = new ArrayList<ColladaPolyList>();
  protected List<ColladaTriangles> trianglesList = new ArrayList<ColladaTriangles>();
  protected List<ColladaTriFans> triFansList = new ArrayList<ColladaTriFans>();
  protected List<ColladaTriStrips> triStripsList = new ArrayList<ColladaTriStrips>();
  protected List<ColladaExtra> extraList = new ArrayList<ColladaExtra>(); 
  
  public ColladaMesh(PApplet pApplet, XML mesh) throws Exception
  {
    super(pApplet, mesh);
    
    parseChildren(mesh, "source", ColladaSource.class, sourceList);
    vertices = parseChild(mesh, "vertices", ColladaVertices.class);
    parseChildren(mesh, "lines", ColladaLines.class, linesList);
    parseChildren(mesh, "linestrips", ColladaLineStrips.class, lineStripsList);
    parseChildren(mesh, "polygons", ColladaPolygons.class, polygonsList);
    parseChildren(mesh, "polylist", ColladaPolyList.class, polyListList);
    parseChildren(mesh, "triangles", ColladaTriangles.class, trianglesList);
    parseChildren(mesh, "trifans", ColladaTriFans.class, triFansList);
    parseChildren(mesh, "tristrips", ColladaTriStrips.class, triStripsList);
    parseChildren(mesh, "extra", ColladaExtra.class, extraList);
  }
  
  public void draw() throws Exception
  {
    for(ColladaTriangles triangles : trianglesList)
    {
      triangles.draw();
    }
  }
}

public static class ColladaP extends ColladaPart
{
  protected List<Integer> content = new ArrayList<Integer>();
  
  public ColladaP(PApplet pApplet, XML p) throws Exception
  {
    super(pApplet, p);
    
    for(String value : p.getContent().split("\\s+"))
    {
      if(value.length() > 0)
      {
        content.add(Integer.valueOf(value));
      }  
    }
  }
  
  public List<Integer> getContent()
  {
    return content;
  }
}

public static class ColladaPolygons extends ColladaPart
{
  public ColladaPolygons(PApplet pApplet, XML polygons) throws Exception
  {
    super(pApplet, polygons);
    PApplet.println("TODO ColladaPolygons");
  }
}

public static class ColladaPolyList extends ColladaPart
{
  public ColladaPolyList(PApplet pApplet, XML polyList) throws Exception
  {
    super(pApplet, polyList);
    PApplet.println("TODO ColladaPolyList");
  }
}

public static class ColladaSpline extends ColladaPart
{
  public ColladaSpline(PApplet pApplet, XML spline) throws Exception
  {
    super(pApplet, spline);
    PApplet.println("TODO ColladaSpline");
  }
}

public static class ColladaTriangles extends ColladaPart
{
  protected String name = null;
  protected Integer count = null;
  protected String material = null;
  
  protected List<ColladaInput> inputList = new ArrayList<ColladaInput>();
  protected ColladaP p = null;
  protected List<ColladaExtra> extraList = new ArrayList<ColladaExtra>();
 
  protected Integer maxOffset = null;
  protected Map<Integer, ColladaInput> inputMap = new HashMap<Integer, ColladaInput>(); 
  
  public ColladaTriangles(PApplet pApplet, XML triangles) throws Exception
  {
    super(pApplet, triangles);
    
    name = parseAttribute(triangles, "name", String.class);
    count = parseAttribute(triangles, "count", Integer.class);
    material = parseAttribute(triangles, "material", String.class);
    
    parseChildren(triangles, "input", ColladaInput.class, inputList);
    p = parseChild(triangles, "p", ColladaP.class);
    parseChildren(triangles, "extra", ColladaExtra.class, extraList);
    
    maxOffset = 0;
    
    for(ColladaInput input : inputList)
    {
      Integer inputOffset = input.getOffset();
      if(inputOffset > maxOffset)
      {
        maxOffset = inputOffset;
      }
    }
    
    for(ColladaInput input : inputList)
    {
      inputMap.put(input.getOffset(),input);
    }
  }
  
  public void draw() throws Exception
  {
    pApplet.beginShape(pApplet.TRIANGLES);
    
    List<Integer> t = p.getContent();
    
    for(Integer triangleIndex = 0; triangleIndex < count; ++triangleIndex)
    { 
      for(Integer vertexIndex = 0; vertexIndex < 3; ++vertexIndex)
      {
        Map<String, Map<String, Object>> map = new HashMap<String, Map<String, Object>>();
      
        for(Integer offset = 0; offset <= maxOffset; ++offset)
        {
          ColladaInput input = inputMap.get(offset);
          if(input == null)
          {
            continue;
          }
          map.putAll(input.getUsingInput(t.get(triangleIndex*3*(maxOffset+1) + vertexIndex*(maxOffset+1) + offset)));
        }
        pApplet.vertex((Float)map.get("POSITION").get("X"), (Float)map.get("POSITION").get("Y"), (Float)map.get("POSITION").get("Z"));
      }  
    }
    
    pApplet.endShape(); 
  }
}

public static class ColladaTriFans extends ColladaPart
{
  public ColladaTriFans(PApplet pApplet, XML triFans) throws Exception
  {
    super(pApplet, triFans);
    PApplet.println("TODO ColladaTriFans");
  }
}

public static class ColladaTriStrips extends ColladaPart
{
  public ColladaTriStrips(PApplet pApplet, XML triStrips) throws Exception
  {
    super(pApplet, triStrips);
    PApplet.println("TODO ColladaTriStrips");
  }
}

public static class ColladaVertices extends ColladaPart
{
  protected String id = null;
  protected String name = null;
  
  protected List<ColladaInput> inputList = new ArrayList<ColladaInput>();
  protected List<ColladaExtra> extraList = new ArrayList<ColladaExtra>();
  
  public ColladaVertices(PApplet pApplet, XML vertices) throws Exception
  {
    super(pApplet, vertices);
    
    id = parseAttribute(vertices, "id", String.class);
    name = parseAttribute(vertices, "name", String.class);
    
    parseChildren(vertices, "input", ColladaInput.class, inputList);
    parseChildren(vertices, "extra", ColladaExtra.class, extraList);
  }
  
  public Map<String, Map<String, Object>> getUsingVertices(Integer index) throws Exception
  {
    Map<String, Map<String, Object>> map = new HashMap<String, Map<String, Object>>();
    for(ColladaInput input : inputList)
    {
      map.putAll(input.getUsingInput(index));
    }
    return map;
  }
}

/* Lighting */

public static class ColladaAmbient extends ColladaPart
{
  public ColladaAmbient(PApplet pApplet, XML ambient) throws Exception
  {
    super(pApplet, ambient);
    PApplet.println("TODO ColladaAmbient");
  }
}

public static class ColladaColor extends ColladaPart
{
  public ColladaColor(PApplet pApplet, XML kolor) throws Exception
  {
    super(pApplet, kolor);
    PApplet.println("TODO ColladaColor");
  }
}

public static class ColladaDirectional extends ColladaPart
{
  public ColladaDirectional(PApplet pApplet, XML directional) throws Exception
  {
    super(pApplet, directional);
    PApplet.println("TODO ColladaDirectional");
  }
}

public static class ColladaInstanceLight extends ColladaPart
{
  public ColladaInstanceLight(PApplet pApplet, XML instanceLight) throws Exception
  {
    super(pApplet, instanceLight);
    PApplet.println("TODO ColladaInstanceLight");
  }
}

public static class ColladaLibraryLights extends ColladaLibrary
{
  public ColladaLibraryLights(PApplet pApplet, XML libraryLights) throws Exception
  {
    super(pApplet, libraryLights);
    PApplet.println("TODO ColladaLibraryLights");
  }
}

public static class ColladaLight extends ColladaPart
{
  public ColladaLight(PApplet pApplet, XML light) throws Exception
  {
    super(pApplet, light);
    PApplet.println("TODO ColladaLight");
  }
}

public static class ColladaPoint extends ColladaPart
{
  public ColladaPoint(PApplet pApplet, XML point) throws Exception
  {
    super(pApplet, point);
    PApplet.println("TODO ColladaPoint");
  }
}

public static class ColladaSpot extends ColladaPart
{
  public ColladaSpot(PApplet pApplet, XML spot) throws Exception
  {
    super(pApplet, spot);
    PApplet.println("TODO ColladaSpot");
  }
}

/* Metadata */

public static class ColladaAsset extends ColladaPart
{
  protected ColladaContributor contributor = null;
  protected ColladaCreated created = null;
  protected ColladaKeywords keywords = null;
  protected ColladaModified modified = null;
  protected ColladaRevision revision = null;
  protected ColladaSubject subject = null;
  protected ColladaTitle title = null;
  protected ColladaUnit unit = null;
  protected ColladaUpAxis upAxis = null;
  
  public ColladaAsset(PApplet pApplet, XML asset) throws Exception
  {
    super(pApplet, asset);
    contributor = parseChild(asset, "contributor", ColladaContributor.class);
    created = parseChild(asset, "created", ColladaCreated.class);
    keywords = parseChild(asset, "keywords", ColladaKeywords.class);
    modified = parseChild(asset, "modified", ColladaModified.class);
    revision = parseChild(asset, "revision", ColladaRevision.class);
    subject = parseChild(asset, "subject", ColladaSubject.class);
    title = parseChild(asset, "title", ColladaTitle.class);
    unit = parseChild(asset, "unit", ColladaUnit.class);
    upAxis = parseChild(asset, "up_axis", ColladaUpAxis.class);
  }
}

public static class ColladaAuthor extends ColladaPart
{
  protected String content = null;
  
  public ColladaAuthor(PApplet pApplet, XML author) throws Exception
  {
    super(pApplet, author);
    content = author.getContent();
  }
}

public static class ColladaAuthoringTool extends ColladaPart
{
  protected String content = null;
  
  public ColladaAuthoringTool(PApplet pApplet, XML authoringTool) throws Exception
  {
    super(pApplet, authoringTool);
    content = authoringTool.getContent();
  }
}

public static class Collada extends ColladaPart
{
  protected String version = null;
  protected String xmlns = null;
  protected String base = null;
  
  protected ColladaAsset asset = null;
  protected List<ColladaLibraryAnimations> libraryAnimationsList = new ArrayList<ColladaLibraryAnimations>();
  protected List<ColladaLibraryAnimationClips> libraryAnimationClipsList = new ArrayList<ColladaLibraryAnimationClips>(); 
  protected List<ColladaLibraryCameras> libraryCamerasList = new ArrayList<ColladaLibraryCameras>();
  protected List<ColladaLibraryControllers> libraryControllersList = new ArrayList<ColladaLibraryControllers>();
  //protected List<ColladaLibraryEffects> libraryEffectsList = new ArrayList<ColladaLibraryEffects>();
  //protected List<ColladaLibraryForceFields> libraryForceFieldsList = new ArrayList<ColladaLibraryForceFields>();
  protected List<ColladaLibraryGeometries> libraryGeometriesList = new ArrayList<ColladaLibraryGeometries>();
  //protected List<ColladaLibraryImages> libraryImagesList = new ArrayList<ColladaLibraryImages>();
  protected List<ColladaLibraryLights> libraryLightsList = new ArrayList<ColladaLibraryLights>();
  //protected List<ColladaLibraryMaterials> libraryMaterialsList = new ArrayList<ColladaLibraryMaterials>();
  protected List<ColladaLibraryNodes> libraryNodesList = new ArrayList<ColladaLibraryNodes>();
  //protected List<ColladaLibraryPhysicsMaterials> libraryPhysicsMaterialsList = new ArrayList<ColladaLibraryPhysicsMaterials>();
  //protected List<ColladaLibraryPhysicsModels> libraryPhysicsModelsList = new ArrayList<ColladaLibraryPhysicsModels>();
  //protected List<ColladaLibraryPhysicsScenes> libraryPhysicsScenesList = new ArrayList<ColladaLibraryPhysicsScenes>();
  protected List<ColladaLibraryVisualScenes> libraryVisualScenesList = new ArrayList<ColladaLibraryVisualScenes>();
  protected ColladaScene scene = null;
  protected List<ColladaExtra> extraList = new ArrayList<ColladaExtra>();
  
  public Collada(PApplet pApplet, XML collada) throws Exception
  {
    super(pApplet, collada);
    version = parseAttribute(collada, "version", String.class);
    xmlns = parseAttribute(collada, "xmlns", String.class);
    base = parseAttribute(collada, "base", String.class);
    
    asset = parseChild(collada, "asset", ColladaAsset.class);
    parseChildren(collada, "library_animations",ColladaLibraryAnimations.class,libraryAnimationsList);
    parseChildren(collada, "library_animation_clips", ColladaLibraryAnimationClips.class, libraryAnimationClipsList);
    parseChildren(collada, "library_cameras", ColladaLibraryCameras.class, libraryCamerasList);
    parseChildren(collada, "library_controllers", ColladaLibraryControllers.class, libraryControllersList);
    //parseChildren(collada, "library_effects", ColladaLibraryEffects.class, libraryEffectsList);
    //parseChildren(collada, "library_force_fields", ColladaLibraryForceFields.class, libraryForceFieldsList);
    parseChildren(collada, "library_geometries", ColladaLibraryGeometries.class, libraryGeometriesList);
    //parseChildren(collada, "library_images", ColladaLibraryImages.class, libraryImagesList);
    parseChildren(collada, "library_lights", ColladaLibraryLights.class, libraryLightsList);
    //parseChildren(collada, "library_materials", ColladaLibraryMaterials.class, libraryMaterialsList);
    parseChildren(collada, "library_nodes", ColladaLibraryNodes.class, libraryNodesList);
    //parseChildren(collada, "library_physics_materials", ColladaLibraryPhysicsMaterials.class, libraryPhysicsMaterialsList);
    //parseChildren(collada, "library_physics_models", ColladaLibraryPhysicsModels.class, libraryPhysicsModelsList);
    //parseChildren(collada, "library_physics_scenes", ColladaLibraryPhysicsScenes.class, libraryPhysicsScenesList);
    parseChildren(collada, "library_visual_scenes", ColladaLibraryVisualScenes.class, libraryVisualScenesList);
    scene = parseChild(collada, "scene", ColladaScene.class);
    parseChildren(collada, "extra", ColladaExtra.class, extraList);
  }
  
  public ColladaScene getScene()
  {
    return scene;
  }
}

public static class ColladaComments extends ColladaPart
{
  protected String content = null;
  
  public ColladaComments(PApplet pApplet, XML comments) throws Exception
  {
    super(pApplet, comments);
    content = comments.getContent();
  }
}

public static class ColladaContributor extends ColladaPart
{
  protected ColladaAuthor author = null;
  protected ColladaAuthoringTool authoringTool = null;
  protected ColladaComments comments = null;
  protected ColladaCopyright copyright = null;
  protected ColladaSourceData sourceData = null;
  
  public ColladaContributor(PApplet pApplet, XML contributor) throws Exception
  {
    super(pApplet, contributor);
    author = parseChild(contributor, "author", ColladaAuthor.class);
    authoringTool = parseChild(contributor, "authoring_tool", ColladaAuthoringTool.class);
    comments = parseChild(contributor, "comments", ColladaComments.class);
    copyright = parseChild(contributor, "copyright", ColladaCopyright.class);
    sourceData = parseChild(contributor, "source_data", ColladaSourceData.class);
  }
}

public static class ColladaCopyright extends ColladaPart
{
  public ColladaCopyright(PApplet pApplet, XML copyright) throws Exception
  {
    super(pApplet, copyright);
    PApplet.println("TODO ColladaCopyright");
  }
}

public static class ColladaCreated extends ColladaPart
{
  protected String content = null;
  
  public ColladaCreated(PApplet pApplet, XML created) throws Exception
  {
    super(pApplet, created);
    content = created.getContent();
  }
}

public static class ColladaKeywords extends ColladaPart
{
  protected String content = null;
  
  public ColladaKeywords(PApplet pApplet, XML keywords) throws Exception
  {
    super(pApplet, keywords);
    content = keywords.getContent();
  }
}

public static class ColladaModified extends ColladaPart
{
  protected String content = null;
  
  public ColladaModified(PApplet pApplet, XML modified) throws Exception
  {
    super(pApplet, modified);
    content = modified.getContent();
  }
}

public static class ColladaRevision extends ColladaPart
{
  protected String content = null;
  
  public ColladaRevision(PApplet pApplet, XML revision) throws Exception
  {
    super(pApplet, revision);
    content = revision.getContent();
  }
}

public static class ColladaSourceData extends ColladaPart
{
  public ColladaSourceData(PApplet pApplet, XML sourceData) throws Exception
  {
    super(pApplet, sourceData);
    PApplet.println("TODO ColladaSourceData");
  }
}

public static class ColladaSubject extends ColladaPart
{
  protected String content = null;
  
  public ColladaSubject(PApplet pApplet, XML subject) throws Exception
  {
    super(pApplet, subject);
    content = subject.getContent();
  }
}

public static class ColladaTitle extends ColladaPart
{
  protected String content = null;
  
  public ColladaTitle(PApplet pApplet, XML title) throws Exception
  {
    super(pApplet, title);
    content = title.getContent();
  }
}

public static class ColladaUnit extends ColladaPart
{
  protected String name = null;
  protected Float meter = null;
  
  public ColladaUnit(PApplet pApplet, XML unit) throws Exception
  {
    super(pApplet, unit);
    name = parseAttribute(unit, "name", String.class, "meter");
    meter = parseAttribute(unit, "meter", Float.class, 1.0);
  }
}

public static class ColladaUpAxis extends ColladaPart
{
  protected String content = "Y_UP";
  
  public ColladaUpAxis(PApplet pApplet, XML upAxis) throws Exception
  {
    super(pApplet, upAxis);
    content = upAxis.getContent();
  }
}

/* Scene */

public static class ColladaEvaluateScene extends ColladaPart
{
  protected String name = null;
  //protected List<ColladaRender> renderList = new ArrayList<ColladaRender>();
  
  public ColladaEvaluateScene(PApplet pApplet, XML evaluateScene) throws Exception
  {
    super(pApplet, evaluateScene);
    
    name = parseAttribute(evaluateScene, "name", String.class);
  }
}

public static class ColladaInstanceNode extends ColladaPart
{
  public ColladaInstanceNode(PApplet pApplet, XML instanceNode) throws Exception
  {
    super(pApplet, instanceNode);
    PApplet.println("TODO ColladaInstanceNode");
  }
}

public static class ColladaInstanceVisualScene extends ColladaPart
{
  protected String sid = null;
  protected String name = null;
  protected String url = null;
  
  public ColladaInstanceVisualScene(PApplet pApplet, XML instanceVisualScene) throws Exception
  {
    super(pApplet, instanceVisualScene);
    sid = parseAttribute(instanceVisualScene, "sid", String.class);
    name = parseAttribute(instanceVisualScene, "name", String.class);
    url = parseAttribute(instanceVisualScene, "url", String.class);
  }
  
  public void draw() throws Exception
  {
    getByURL(url, ColladaVisualScene.class).draw();
  }
}

public static class ColladaLibraryNodes extends ColladaLibrary
{
  public ColladaLibraryNodes(PApplet pApplet, XML libraryNodes) throws Exception
  {
    super(pApplet, libraryNodes);
    PApplet.println("TODO ColladaLibraryNodes");
  }
}

public static class ColladaLibraryVisualScenes extends ColladaLibrary
{
  protected String id = null;
  protected String name = null;
  
  protected ColladaAsset asset = null;
  protected List<ColladaVisualScene> visualSceneList = new ArrayList<ColladaVisualScene>();
  protected List<ColladaExtra> extraList = new ArrayList<ColladaExtra>();
  
  public ColladaLibraryVisualScenes(PApplet pApplet, XML libraryVisualScenes) throws Exception
  {
    super(pApplet, libraryVisualScenes);
    
    id = parseAttribute(libraryVisualScenes, "id", String.class);
    name = parseAttribute(libraryVisualScenes, "name", String.class);
    
    asset = parseChild(libraryVisualScenes, "asset", ColladaAsset.class);
    parseChildren(libraryVisualScenes, "visual_scene", ColladaVisualScene.class, visualSceneList);
    parseChildren(libraryVisualScenes, "extra", ColladaExtra.class, extraList);
  }
}

public static class ColladaNode extends ColladaPart
{
  protected String id = null;
  protected String name = null;
  protected String sid = null;
  protected String type = null;
  protected List<String> layerList = new ArrayList<String>();
  
  protected ColladaAsset asset = null;
  protected List<ColladaLookAt> lookAtList = new ArrayList<ColladaLookAt>();
  protected List<ColladaMatrix> matrixList = new ArrayList<ColladaMatrix>();
  protected List<ColladaRotate> rotateList = new ArrayList<ColladaRotate>();
  protected List<ColladaScale> scaleList = new ArrayList<ColladaScale>();
  protected List<ColladaSkew> skewList = new ArrayList<ColladaSkew>();
  protected List<ColladaTranslate> translateList = new ArrayList<ColladaTranslate>();
  protected List<ColladaInstanceCamera> instanceCameraList = new ArrayList<ColladaInstanceCamera>();
  protected List<ColladaInstanceController> instanceControllerList = new ArrayList<ColladaInstanceController>();
  protected List<ColladaInstanceGeometry> instanceGeometryList = new ArrayList<ColladaInstanceGeometry>();
  protected List<ColladaInstanceLight> instanceLightList = new ArrayList<ColladaInstanceLight>();
  protected List<ColladaInstanceNode> instanceNodeList = new ArrayList<ColladaInstanceNode>();
  protected List<ColladaNode> nodeList = new ArrayList<ColladaNode>();
  protected List<ColladaExtra> extraList = new ArrayList<ColladaExtra>();
  
  public ColladaNode(PApplet pApplet, XML node) throws Exception
  {
    super(pApplet, node);
    id = parseAttribute(node, "id", String.class);
    name = parseAttribute(node, "name", String.class);
    sid = parseAttribute(node, "sid", String.class);
    type = parseAttribute(node, "type", String.class);
    String layers = parseAttribute(node, "layer", String.class);
    if(layers != null)
    {
      for(String layer : layers.split("\\s+"))
      {
        if(layer.length() > 0)
        {
          layerList.add(layer);
        }
      }
    }
    
    asset = parseChild(node, "asset", ColladaAsset.class);
    parseChildren(node, "lookat", ColladaLookAt.class, lookAtList);
    parseChildren(node, "matrix", ColladaMatrix.class, matrixList);
    parseChildren(node, "rotate", ColladaRotate.class, rotateList);
    parseChildren(node, "scale", ColladaScale.class, scaleList);
    parseChildren(node, "skew", ColladaSkew.class, skewList);
    parseChildren(node, "translate", ColladaTranslate.class, translateList);
    parseChildren(node, "instance_camera", ColladaInstanceCamera.class, instanceCameraList);
    parseChildren(node, "instance_controller", ColladaInstanceController.class, instanceControllerList);
    parseChildren(node, "instance_geometry", ColladaInstanceGeometry.class, instanceGeometryList);
    parseChildren(node, "instance_light", ColladaInstanceLight.class, instanceLightList);
    parseChildren(node, "instance_node", ColladaInstanceNode.class, instanceNodeList);
    parseChildren(node, "node", ColladaNode.class, nodeList);
    parseChildren(node, "extra", ColladaExtra.class, extraList);
  }
  
  public void draw() throws Exception
  {
    pApplet.pushMatrix();
    for(ColladaMatrix matrix : matrixList)
    {
      // apply matrix
    }
    for(ColladaInstanceGeometry instanceGeometry : instanceGeometryList)
    {
      instanceGeometry.draw();
    }
    pApplet.popMatrix();
  }
}

public static class ColladaScene extends ColladaPart
{
  //protected List<ColladaInstancePhysicsScene> instancePhysicsSceneList = new ArrayList<ColladaInstancePhysicsScene>();
  protected ColladaInstanceVisualScene instanceVisualScene = null;
  protected List<ColladaExtra> extraList = new ArrayList<ColladaExtra>();
  
  public ColladaScene(PApplet pApplet, XML scene) throws Exception
  {
    super(pApplet, scene);
    //parseChildren(scene, "instance_physics_scene",ColladaInstancePhysicsScene.class,instancePhysicsSceneList);
    instanceVisualScene = parseChild(scene, "instance_visual_scene", ColladaInstanceVisualScene.class);
    parseChildren(scene, "extra",ColladaExtra.class,extraList);    
  }
  
  public void draw() throws Exception
  {
    if(instanceVisualScene != null)
    {
      instanceVisualScene.draw();
    }
  }
}

public static class ColladaVisualScene extends ColladaPart
{
  protected String id = null;
  protected String name = null;
  
  protected ColladaAsset asset = null;
  protected List<ColladaNode> nodeList = new ArrayList<ColladaNode>();
  protected List<ColladaEvaluateScene> evaluateSceneList = new ArrayList<ColladaEvaluateScene>();
  protected List<ColladaExtra> extraList = new ArrayList<ColladaExtra>();
  
  public ColladaVisualScene(PApplet pApplet, XML visualScene) throws Exception
  {
    super(pApplet, visualScene);
    id = parseAttribute(visualScene, "id", String.class);
    name = parseAttribute(visualScene, "name", String.class);
    
    asset = parseChild(visualScene, "asset", ColladaAsset.class);
    parseChildren(visualScene, "node", ColladaNode.class, nodeList);
    parseChildren(visualScene, "evaluate_scene", ColladaEvaluateScene.class, evaluateSceneList);
    parseChildren(visualScene, "extra", ColladaExtra.class, extraList);
  }
  
  public void draw() throws Exception
  {
    for(ColladaNode node : nodeList)
    {
      node.draw();
    }
  }
}

/* Transform */

public static class ColladaLookAt extends ColladaPart
{
  public ColladaLookAt(PApplet pApplet, XML lookAt) throws Exception
  {
    super(pApplet, lookAt);
    PApplet.println("TODO ColladaLookAt");
  }
}

public static class ColladaMatrix extends ColladaPart
{
  protected String sid = null;
  protected float[][] content = new float[4][4];
  
  public ColladaMatrix(PApplet pApplet, XML matrix) throws Exception
  {
    super(pApplet, matrix);
    
    sid = parseAttribute(matrix, "sid", String.class);
    
    Integer i = 0;
    Integer j = 0;
    for(String value : matrix.getContent().split("\\s+"))
    {
      if(value.length() > 0)
      {
        content[i][j] = Float.valueOf(value);
        if(++i >= 4)
        {
          i = 0;
          ++j;
        }
      }
    }
  }
}

public static class ColladaRotate extends ColladaPart
{
  public ColladaRotate(PApplet pApplet, XML rotate) throws Exception
  {
    super(pApplet, rotate);
    PApplet.println("TODO ColladaRotate");
  }
}

public static class ColladaScale extends ColladaPart
{
  public ColladaScale(PApplet pApplet, XML scale) throws Exception
  {
    super(pApplet, scale);
    PApplet.println("TODO ColladaScale");
  }
}

public static class ColladaSkew extends ColladaPart
{
  public ColladaSkew(PApplet pApplet, XML skew) throws Exception
  {
    super(pApplet, skew);
    PApplet.println("TODO ColladaSkew");
  }
}

public static class ColladaTranslate extends ColladaPart
{
  public ColladaTranslate(PApplet pApplet, XML translate) throws Exception
  {
    super(pApplet, translate);
    PApplet.println("TODO ColladaTranslate");
  }
}
