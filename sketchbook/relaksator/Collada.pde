import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.ArrayList;
import java.util.Deque;
import java.util.LinkedList;
import java.util.Arrays;
import java.util.Map;
import java.util.HashMap;
import java.util.regex.Pattern;
import java.util.regex.Matcher;
import papaya.Mat;

public static interface HavingContent<T>
{
  public abstract T getContent();
  public abstract void setContent(T content);
  public abstract void reset();
  public abstract Integer getVersion();
}

public static abstract class ColladaPart
{
  protected PApplet pApplet = null;
  protected ColladaPart parent = null;
  protected static Map<String, List<ColladaPart>> sidMap = new HashMap<String, List<ColladaPart>>();
  private static Map<String, ColladaPart> idMap = new HashMap<String, ColladaPart>();
  protected static Pattern sidPathPattern = Pattern.compile("\\A(\\.|\\w+)(/\\w+)*(\\.\\w+|(?:\\(\\p{Digit}+\\)){0,2})\\z");
  protected static Pattern selfPattern = Pattern.compile("\\A\\.\\z");
  protected static Pattern structureElementPattern = Pattern.compile("\\A\\.(\\w)+\\z");
  protected static Pattern arrayPattern = Pattern.compile("\\A\\((\\p{Digit}+)\\)\\z"); 
  protected static Pattern matrixPattern = Pattern.compile("\\A\\((\\p{Digit}+)\\)\\((\\p{Digit}+)\\)\\z");
  
  private String myId = null;
  private String mySid = null;
  
  protected ColladaPart(PApplet pApplet, XML element, ColladaPart parent) throws Exception
  {
    pApplet.println("Tworzę obiekt klasy: "+this.getClass().getName());
    this.pApplet = pApplet;
    this.parent = parent;

    if((myId = element.getString("id")) != null)
    {
      idMap.put(myId, this); 
    }        
    
    if((mySid = element.getString("sid")) != null)
    {
      List<ColladaPart> partList = sidMap.get(mySid);
      if(partList == null)
      {
        partList = new ArrayList<ColladaPart>();
        sidMap.put(mySid, partList); 
      }
      partList.add(this);
    }
  }
  
  public <T> T parseChild(XML parent, String childName, Class<T> type) throws Exception
  {
    XML child = parent.getChild(childName);
    if(child != null)
    {
      return Helper.construct(type, new Class<?>[] {PApplet.class, XML.class, ColladaPart.class}, new Object[] {pApplet, child, this});
    }
    else
    {
      return null;
    }
  }

  public <T> T parseChild(XML parent, String childName, Class<T> type, Class<?>[] argumentTypes, Object[] arguments) throws Exception
  {
    XML child = parent.getChild(childName);
    
    if(child != null)
    {
      Class<?>[] constructorArgumentTypes = new Class<?>[3+argumentTypes.length];
      constructorArgumentTypes[0] = PApplet.class;
      constructorArgumentTypes[1] = XML.class;
      constructorArgumentTypes[2] = ColladaPart.class;
      for(Integer i = 0; i < argumentTypes.length; ++i)
      {
        constructorArgumentTypes[i+3] = argumentTypes[i];
      }
      Object[] constructorArguments = new Object[3+argumentTypes.length];
      constructorArguments[0] = pApplet;
      constructorArguments[1] = child;
      constructorArguments[2] = this;
      for(Integer i = 0; i < arguments.length; ++i)
      {
        constructorArguments[i+3] = arguments[i];
      }      
      
      return Helper.construct(type, constructorArgumentTypes, constructorArguments);
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
      collection.add(Helper.construct(type, new Class<?>[] {PApplet.class, XML.class, ColladaPart.class}, new Object[] {pApplet, child, this}));
    }    
  }  
  
  public <T> void parseChildren(XML parent, String childName, Class<T> type, Class<?>[] argumentTypes, Object[] arguments, Collection<T> collection) throws Exception
  {
    Class<?>[] constructorArgumentTypes = new Class<?>[2+argumentTypes.length];
    constructorArgumentTypes[0] = PApplet.class;
    constructorArgumentTypes[1] = XML.class;
    for(Integer i = 0; i < argumentTypes.length; ++i)
    {
      constructorArgumentTypes[i+2] = argumentTypes[i];
    }
    Object[] constructorArguments = new Object[2+argumentTypes.length];
    constructorArguments[0] = pApplet;
    for(Integer i = 0; i < arguments.length; ++i)
    {
      constructorArguments[i+2] = arguments[i];
    }          
    
    for(XML child : parent.getChildren(childName))
    {
      constructorArguments[1] = child;      
      collection.add(Helper.construct(type, constructorArgumentTypes, constructorArguments));
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
  
  public Boolean hasSidPath(ColladaPart root, Deque<String> sidDeque)
  {
    if(root == this)
    {
      if(sidDeque.size() == 0)
      {
        return true;
      }
      else
      {
        return false;
      }
    }
    if(parent == null)
    {
      return false;
    }
    if(sidDeque.size() != 0 && mySid.equals(sidDeque.getLast()))
    {
      sidDeque.removeLast();
    }
    return parent.hasSidPath(root, sidDeque);
  }

  public ColladaPart getBySidPath(String sidPath) throws Exception
  {
    Matcher sidPathMatcher = sidPathPattern.matcher(sidPath);
    if(!sidPathMatcher.matches())
    {
      throw new Exception("The following sid path is incorrect: "+sidPath);
    }
    
    String id = sidPathMatcher.group(1);
    String sids = sidPathMatcher.group(2);
    String rest = sidPathMatcher.group(3);
    
    ColladaPart root = null;
    
    if(selfPattern.matcher(id).matches())
    {
      root = this;
    }
    else
    {
      root = getById(id);
    }
    
    Integer firstIndex = null;
    Integer secondIndex = null;
    
    Matcher arrayMatcher = arrayPattern.matcher(rest);
    Matcher matrixMatcher = matrixPattern.matcher(rest);
    Matcher structureElementMatcher = structureElementPattern.matcher(rest); 
    
    if(matrixMatcher.matches())
    {
      firstIndex = Integer.valueOf(matrixMatcher.group(1));
      secondIndex = Integer.valueOf(matrixMatcher.group(2));
      throw new Exception("TODO sid matrix indexes");
    }
    else if(arrayMatcher.matches())
    {
      firstIndex = Integer.valueOf(arrayMatcher.group(1));
      throw new Exception("TODO sid array indexes");
    }
    else if(structureElementMatcher.matches())
    {
      throw new Exception("TODO sid structure element");
    }
    
    if(sids == null || sids.equals(""))
    {
      return root;
    }
    else
    {
      Deque<String> sidDeque = new LinkedList<String>(Arrays.asList(sids.split("/")));
      sidDeque.removeFirst();
      for(ColladaPart part : sidMap.get(sidDeque.getLast()))
      {
        if(part.hasSidPath(root, (Deque<String>)((LinkedList<String>)sidDeque).clone()))
        {
          return part;
        }
      }      
    }
    throw new Exception("Cannot find by using the path: "+sidPath);
  }
  
  public static ColladaPart getById(String id)
  {
    return idMap.get(id);
  }

  public static ColladaPart getByURL(String url)
  {
    return idMap.get(url.substring(1));
  }
  
}

public static abstract class ColladaLibrary extends ColladaPart
{
  public ColladaLibrary(PApplet pApplet, XML library, ColladaPart parent) throws Exception
  {
    super(pApplet, library, parent);
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
  
  protected Long startTime = null;
  protected Long startAnimation = null;
  protected Long stopAnimation = null;
  
  public ColladaAnimation(PApplet pApplet, XML animation, ColladaPart parent) throws Exception
  {
    super(pApplet, animation, parent);
    
    id = parseAttribute(animation, "id", String.class);
    name = parseAttribute(animation, "name", String.class);
    
    asset = parseChild(animation, "asset", ColladaAsset.class);
    parseChildren(animation, "animation", ColladaAnimation.class, animationList);
    parseChildren(animation, "source", ColladaSource.class, sourceList);
    parseChildren(animation, "sampler", ColladaSampler.class, samplerList);
    parseChildren(animation, "channel", ColladaChannel.class, channelList);
    parseChildren(animation, "extra", ColladaExtra.class, extraList);
  }
  
  public void start(Long startTime, Long startAnimation, Long stopAnimation)
  {
    for(ColladaAnimation animation : animationList)
    {
      animation.start(startTime, startAnimation, stopAnimation);
    }
    
    this.startTime = startTime;
    this.startAnimation = startAnimation;
    this.stopAnimation = stopAnimation;
  } 
  
  public void stop() throws Exception
  {
    startTime = null;
    for(ColladaAnimation animation : animationList)
    {
      animation.stop();
    }    
    
    for(ColladaChannel channel : channelList)
    {
      channel.reset();
    }
  }
  
  public void run() throws Exception
  {
    
    Long currentTime = System.currentTimeMillis();
    
    for(ColladaAnimation animation : animationList)
    {
      animation.run();
    }
    
    if(startTime == null)
    {
      return;
    }
    if(currentTime >= startTime+(stopAnimation-startAnimation))
    {
      stop();
      return;
    }
    for(ColladaChannel channel : channelList)
    {
      channel.forwardFor((startAnimation + currentTime - startTime)/1000.0);
    }
     
  }
}

public static class ColladaAnimationClip extends ColladaPart
{
  public ColladaAnimationClip(PApplet pApplet, XML animationClip, ColladaPart parent) throws Exception
  {
    super(pApplet, animationClip, parent);
    PApplet.println("TODO ColladaAnimationClip");
  }
}

public static class ColladaChannel extends ColladaPart
{
  protected String source = null;
  protected String target = null;
  
  public ColladaChannel(PApplet pApplet, XML channel, ColladaPart parent) throws Exception
  {
    super(pApplet, channel, parent);
    
    source = parseAttribute(channel, "source", String.class);
    target = parseAttribute(channel, "target", String.class);
  }
  
  public void forwardFor(Float time) throws Exception
  {
    ColladaSampler sampler = (ColladaSampler)getByURL(source);
    HavingContent<Object> container = (HavingContent<Object>)getBySidPath(target);
    container.setContent(sampler.getAtTime(time));
  }
  
  public void reset() throws Exception
  {
    HavingContent<Object> container = (HavingContent<Object>)getBySidPath(target);
    container.reset();
  }
}

public static class ColladaInstanceAnimation extends ColladaPart
{
  public ColladaInstanceAnimation(PApplet pApplet, XML instanceAnimation, ColladaPart parent) throws Exception
  {
    super(pApplet, instanceAnimation, parent);
    PApplet.println("TODO ColladaInstanceAnimation");
  }
}

public static class ColladaLibraryAnimationClips extends ColladaLibrary
{
  public ColladaLibraryAnimationClips(PApplet pApplet, XML libraryAnimationClips, ColladaPart parent) throws Exception
  {
    super(pApplet, libraryAnimationClips, parent);
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
  
  public ColladaLibraryAnimations(PApplet pApplet, XML libraryAnimations, ColladaPart parent) throws Exception
  {
    super(pApplet, libraryAnimations, parent);
    
    id = parseAttribute(libraryAnimations, "id", String.class);
    name = parseAttribute(libraryAnimations, "name", String.class);
 
    asset = parseChild(libraryAnimations, "asset", ColladaAsset.class);
    parseChildren(libraryAnimations, "animation", ColladaAnimation.class, animationList);
    parseChildren(libraryAnimations, "extra", ColladaExtra.class, extraList);
  }
  
  public void run() throws Exception
  {
    for(ColladaAnimation animation : animationList)
    {
      animation.run();
    }
  }
}

public static class ColladaSampler extends ColladaPart
{
  protected String id = null;
  
  protected List<ColladaInput> inputList = new ArrayList<ColladaInput>();
  
  protected List<Float> timeList = new ArrayList<Float>();
  protected List<Object> contentList = new ArrayList<Object>();
  protected List<String> interpolationList = new ArrayList<String>();
  
  public ColladaSampler(PApplet pApplet, XML sampler, ColladaPart parent) throws Exception
  {
    super(pApplet, sampler, parent);
    
    id = parseAttribute(sampler, "id", String.class);
    
    parseChildren(sampler, "input", ColladaInput.class, inputList);
    
    for(ColladaInput input : inputList)
    {
      if(input.getSemantic().equals("INPUT"))
      {
        for(Integer i = 0; i < input.getCount(); ++i)
        {
          timeList.add((Float)input.getUsingInput(i).get("INPUT").get("TIME"));
        }
      }
      if(input.getSemantic().equals("OUTPUT"))
      {
        for(Integer i = 0; i < input.getCount(); ++i)
        {
          Map<String, Object> map = input.getUsingInput(i).get("OUTPUT");
          for(String k : map.keySet())
          {
            contentList.add(map.get(k));
            break;
          }          
        }        
      }
      if(input.getSemantic().equals("INTERPOLATION"))
      {
        for(Integer i = 0; i < input.getCount(); ++i)
        {
          interpolationList.add((String)input.getUsingInput(i).get("INTERPOLATION").get("name"));          
        }        
      }        
    }
  }
  
  public Object getAtTime(Float time)
  {
    Integer index = Collections.binarySearch(timeList, time);
    if(index >= 0)
    {
      return contentList.get(index);
    }
    else
    {
      return contentList.get(-index-2);
    }
  }
}

/* Camera */

public static class ColladaCamera extends ColladaPart
{
  public ColladaCamera(PApplet pApplet, XML camera, ColladaPart parent) throws Exception
  {
    super(pApplet, camera, parent);
    PApplet.println("TODO ColladaCamera");
  }
}

public static class ColladaImager extends ColladaPart
{
  public ColladaImager(PApplet pApplet, XML imager, ColladaPart parent) throws Exception
  {
    super(pApplet, imager, parent);
    PApplet.println("TODO ColladaImager");
  }
}

public static class ColladaInstanceCamera extends ColladaPart
{
  public ColladaInstanceCamera(PApplet pApplet, XML instanceCamera, ColladaPart parent) throws Exception
  {
    super(pApplet, instanceCamera, parent);
    PApplet.println("TODO ColladaInstanceCamera");
  }
}

public static class ColladaLibraryCameras extends ColladaLibrary
{
  public ColladaLibraryCameras(PApplet pApplet, XML libraryCameras, ColladaPart parent) throws Exception
  {
    super(pApplet, libraryCameras, parent);
    PApplet.println("TODO ColladaLibraryCameras");
  }
}

public static class ColladaOptics extends ColladaPart
{
  public ColladaOptics(PApplet pApplet, XML optics, ColladaPart parent) throws Exception
  {
    super(pApplet, optics, parent);
    PApplet.println("TODO ColladaOptics");
  }
}

public static class ColladaOrthographic extends ColladaPart
{
  public ColladaOrthographic(PApplet pApplet, XML orthographic, ColladaPart parent) throws Exception
  {
    super(pApplet, orthographic, parent);
    PApplet.println("TODO ColladaOrthographic");
  }
}

public static class ColladaPerspective extends ColladaPart
{
  public ColladaPerspective(PApplet pApplet, XML perspective, ColladaPart parent) throws Exception
  {
    super(pApplet, perspective, parent);
    PApplet.println("TODO ColladaPerspective");
  }
}
/* Controller */

public static class ColladaBindShapeMatrix extends ColladaPart
{
  protected float[][] content = new float[4][4];
  
  public ColladaBindShapeMatrix(PApplet pApplet, XML bindShapeMatrix, ColladaPart parent) throws Exception
  {
    super(pApplet, bindShapeMatrix, parent);
    
    Integer i = 0;
    Integer j = 0;
    for(String value : bindShapeMatrix.getContent().split("\\s+"))
    {
      if(value.length() > 0)
      {
        content[i][j] = Float.valueOf(value);
        if(++j >= 4)
        {
          j = 0;
          ++i;
        }
      }
    }
  }
  
  public float[][] getContent()
  {
    return content;
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
  
  public ColladaController(PApplet pApplet, XML controller, ColladaPart parent) throws Exception
  {
    super(pApplet, controller, parent);
    
    id = parseAttribute(controller, "id", String.class);
    name = parseAttribute(controller, "name", String.class);
    
    asset = parseChild(controller, "asset", ColladaAsset.class);
    skin = parseChild(controller, "skin", ColladaSkin.class);
    morph = parseChild(controller, "morph", ColladaMorph.class);
    parseChildren(controller, "extra", ColladaExtra.class, extraList);
  }
  
  public void draw() throws Exception
  {
    if(skin != null)
    {
      skin.draw();
    }
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
  
  public ColladaInstanceController(PApplet pApplet, XML instanceController, ColladaPart parent) throws Exception
  {
    super(pApplet, instanceController, parent);
    
    sid = parseAttribute(instanceController, "sid", String.class);
    name = parseAttribute(instanceController, "name", String.class);
    url = parseAttribute(instanceController, "url", String.class);
    
    parseChildren(instanceController, "skeleton", ColladaSkeleton.class, skeletonList);
    //bindMaterial = parseChild(instanceController, "bind_material", ColladaBindMaterial.class);
    parseChildren(instanceController, "extra", ColladaExtra.class, extraList); 
  }
  
  public void draw() throws Exception
  {
    ((ColladaController)getByURL(url)).draw();
  }  
}

public static class ColladaJoints extends ColladaPart
{
  protected List<ColladaInput> inputList = new ArrayList<ColladaInput>();
  protected List<ColladaExtra> extraList = new ArrayList<ColladaExtra>();
  
  protected List<String> jointsList = new ArrayList<String>();
  protected List<float[][]> inverseBindPoseMatrixList = new ArrayList<float[][]>();
  
  public ColladaJoints(PApplet pApplet, XML joints, ColladaPart parent) throws Exception
  {
    super(pApplet, joints, parent);
    
    parseChildren(joints, "input", ColladaInput.class, inputList);
    parseChildren(joints, "extra", ColladaExtra.class, extraList);
    
    for(ColladaInput input : inputList)
    {
      if(input.getSemantic().equals("JOINT"))
      {
        for(Integer i = 0; i < input.getCount(); ++i)
        {
          jointsList.add((String)input.getUsingInput(i).get("JOINT").get("name"));
        }
      }
      if(input.getSemantic().equals("INV_BIND_MATRIX"))
      {   
        for(Integer i = 0; i < input.getCount(); ++i)
        {
          inverseBindPoseMatrixList.add((float[][])input.getUsingInput(i).get("INV_BIND_MATRIX").get("float4x4"));
        }
      }  
    }
    if(jointsList.size() != inverseBindPoseMatrixList.size())
    {
      throw new Exception("The number of joints is not equal to the number of the matrices");
    }    
  }
  
  public Integer getCount()
  {
    return jointsList.size();
  }
  
  public float[][] getInverseBindPoseMatrix(Integer i)
  {
    return inverseBindPoseMatrixList.get(i);
  }
  
  public float[][] getJointMatrix(Integer i) throws Exception
  {
    return ((ColladaNode)getBySidPath((String)jointsList.get(i))).getMatrix();
  }
  
}

public static class ColladaLibraryControllers extends ColladaLibrary
{
  protected String id = null;
  protected String name = null;
  
  protected ColladaAsset asset = null;
  protected List<ColladaController> controllerList = new ArrayList<ColladaController>();
  protected List<ColladaExtra> extraList = new ArrayList<ColladaExtra>();
  
  public ColladaLibraryControllers(PApplet pApplet, XML libraryControllers, ColladaPart parent) throws Exception
  {
    super(pApplet, libraryControllers, parent);
    
    id = parseAttribute(libraryControllers, "id", String.class);
    name = parseAttribute(libraryControllers, "name", String.class);
    
    asset = parseChild(libraryControllers, "asset", ColladaAsset.class);
    parseChildren(libraryControllers, "controller", ColladaController.class, controllerList);
    parseChildren(libraryControllers, "extra", ColladaExtra.class, extraList);
  }
}

public static class ColladaMorph extends ColladaPart
{
  public ColladaMorph(PApplet pApplet, XML morph, ColladaPart parent) throws Exception
  {
    super(pApplet, morph, parent);
    PApplet.println("TODO ColladaMorph");
  }
}

public static class ColladaSkeleton extends ColladaPart
{
  public ColladaSkeleton(PApplet pApplet, XML skeleton, ColladaPart parent) throws Exception
  {
    super(pApplet, skeleton, parent);
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
  
  protected List<float[][]> combinedBindMatrixList = new ArrayList<float[][]>();
  
  public ColladaSkin(PApplet pApplet, XML skin, ColladaPart parent) throws Exception
  {
    super(pApplet, skin, parent);
    
    sourceAttr = parseAttribute(skin, "source", String.class);
    
    bindShapeMatrix = parseChild(skin, "bind_shape_matrix", ColladaBindShapeMatrix.class);
    parseChildren(skin, "source", ColladaSource.class, sourceList);   
    joints = parseChild(skin, "joints", ColladaJoints.class);
    vertexWeights = parseChild(skin, "vertex_weights", ColladaVertexWeights.class);
    parseChildren(skin, "extra", ColladaExtra.class, extraList);
    
    for(Integer i = 0; i < joints.getCount(); ++i)
    {
      if(bindShapeMatrix == null)
      {
        combinedBindMatrixList.add(joints.getInverseBindPoseMatrix(i));
      }
      else
      {
        combinedBindMatrixList.add(Mat.multiply(joints.getInverseBindPoseMatrix(i),bindShapeMatrix.getContent()));        
      }
    }
  }
  
  public void draw() throws Exception
  {
    //Long time = System.currentTimeMillis();
    
    List<float[][]> matrixList = new ArrayList<float[][]>();
    for(Integer i = 0; i < combinedBindMatrixList.size(); ++i)
    {
      matrixList.add(Mat.multiply(joints.getJointMatrix(i),combinedBindMatrixList.get(i)));
    }
    
    //pApplet.println("1 skin draw: "+String.valueOf(System.currentTimeMillis()-time));
    
    List<Map<Integer, Float>> weightMapList = vertexWeights.getContent();
        
    ColladaGeometry geometry = ((ColladaGeometry)getByURL(sourceAttr));
    ColladaFloatArray floatArray = ((ColladaTechniqueCommonInSource)geometry.getMesh().getVertices().getPositionsSource().getTechnique()).getAccessor().getSource(ColladaFloatArray.class);
    List<Float> oldVertexList = floatArray.getContent();
    List<Float> newVertexList = new ArrayList<Float>();
    
    //pApplet.println("2 skin draw: "+String.valueOf(System.currentTimeMillis()-time));    
    
    for(Integer i = 0; i < oldVertexList.size(); i += 3)
    {
        Integer vertexIndex = i / 3;
        Map<Integer, Float> weightMap = weightMapList.get(vertexIndex);
        
        float[] oldVertex = new float[] {oldVertexList.get(i), oldVertexList.get(i+1), oldVertexList.get(i+2), 1.0};
        float[] newVertex = new float[] {0.0, 0.0, 0.0, 0.0};
        
        for(Integer k : weightMap.keySet())
        {
          newVertex = Mat.sum(newVertex,Mat.multiply(Mat.multiply(matrixList.get(k),oldVertex), weightMap.get(k))); 
        }
        
        newVertexList.add((Float)newVertex[0]);
        newVertexList.add((Float)newVertex[1]);
        newVertexList.add((Float)newVertex[2]);
    }
    
    //pApplet.println("3 skin draw: "+String.valueOf(System.currentTimeMillis()-time));      
    
    floatArray.setContent(newVertexList);
    
    //pApplet.println("4 skin draw: "+String.valueOf(System.currentTimeMillis()-time));
    
    geometry.draw();
    
    //pApplet.println("5 skin draw: "+String.valueOf(System.currentTimeMillis()-time));    
    
    floatArray.reset();
    //pApplet.println("skin draw: "+String.valueOf(System.currentTimeMillis()-time));
  }
}

public static class ColladaTargets extends ColladaPart
{
  public ColladaTargets(PApplet pApplet, XML targets, ColladaPart parent) throws Exception
  {
    super(pApplet, targets, parent);
    PApplet.println("TODO ColladaTargets");
  }
}

public static class ColladaV extends ColladaPart
{
  protected List<Integer> content = new ArrayList<Integer>();
  
  public ColladaV(PApplet pApplet, XML v, ColladaPart parent) throws Exception
  {
    super(pApplet, v, parent);

    for(String value : v.getContent().split("\\s+"))
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

public static class ColladaVCount extends ColladaPart
{
  protected List<Integer> content = new ArrayList<Integer>();  
  
  public ColladaVCount(PApplet pApplet, XML vCount, ColladaPart parent) throws Exception
  {
    super(pApplet, vCount, parent);
    
    for(String value : vCount.getContent().split("\\s+"))
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

public static class ColladaVertexWeights extends ColladaPart
{
  protected Integer count = null;
  
  protected List<ColladaInput> inputList = new ArrayList<ColladaInput>();
  protected ColladaVCount vCount = null;
  protected ColladaV v = null;
  protected List<ColladaExtra> extraList = new ArrayList<ColladaExtra>();
  
  protected Integer maxOffset = null;
  protected Map<Integer, ColladaInput> inputMap = new HashMap<Integer, ColladaInput>(); 
  
  protected List<Map<Integer, Float>> content = new ArrayList<Map<Integer, Float>>();
  
  public ColladaVertexWeights(PApplet pApplet, XML vertexWeights, ColladaPart parent) throws Exception
  {
    super(pApplet, vertexWeights, parent);
    
    count = parseAttribute(vertexWeights, "count", Integer.class);
    
    parseChildren(vertexWeights, "input", ColladaInput.class, inputList);
    vCount = parseChild(vertexWeights, "vcount", ColladaVCount.class);
    v = parseChild(vertexWeights, "v", ColladaV.class);
    parseChildren(vertexWeights, "extra", ColladaExtra.class, extraList);
    
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
        
    Integer j = 0;
    for(Integer i = 0; i < count; ++i)
    {
      Integer jointsCount = vCount.getContent().get(i);
      Map<Integer,  Float> map = new HashMap<Integer, Float>();
      content.add(map);
      
      for(Integer k = j; k < j + jointsCount; ++k)
      { 
        Integer jointIndex = null;
        Float jointWeight = null;
        
        for(Integer offset = 0; offset <= maxOffset; ++offset)
        {
          ColladaInput input = inputMap.get(offset);
          if(input == null)
          {
            continue;
          }
          if(input.getSemantic().equals("JOINT"))
          {
            jointIndex = (Integer)v.getContent().get(k*(maxOffset+1)+offset);
          }
          else if(input.getSemantic().equals("WEIGHT"))
          {
            jointWeight = (Float)input.getUsingInput(v.getContent().get(k*(maxOffset+1)+offset)).get("WEIGHT").get("float");
          }
        }
        map.put(jointIndex, jointWeight);
      }
      
      j += jointsCount;
    }
  }
  
  public List<Map<Integer, Float>> getContent()
  {
    return content;
  }
}
 
/* Data Flow */

public static class ColladaAccessor extends ColladaPart
{
  protected Integer count = null;
  protected Integer offset = null;
  protected String source = null;
  protected Integer stride = null;
  
  protected HavingContent<List<Object>> lazySource  = null;
  protected Integer sourceVersion = null;
  protected List<Map<String, Object>> mapList = null;
  
  protected List<ColladaParam> paramList = new ArrayList<ColladaParam>();
  
  public ColladaAccessor(PApplet pApplet, XML accessor, ColladaPart parent) throws Exception
  {
    super(pApplet, accessor, parent);
    
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
  
  public <T> T getSource(Class<T> type)
  {
    return (T)getByURL(source);
  }
  
  private void initialize() throws Exception
  {
    mapList = new ArrayList<Map<String, Object>>();
    lazySource = (HavingContent<List<Object>>)getByURL(source);
    sourceVersion = lazySource.getVersion();
    for(Integer index = 0; index < count; ++index)
    {
      Map<String, Object> map = new HashMap<String, Object>();
      Deque<Object> deque = new LinkedList<Object>(lazySource.getContent().subList(offset + index*stride, offset+(index+1)*stride));
    
      for(Integer i = 0; i < paramList.size(); ++i)
      {
        ColladaParam param = paramList.get(i);
        String paramName = param.getName();
        if(paramName == null)
        {
          if(map.get(param.getType()) == null)
          {
            paramName = param.getType();
          }
          else
          {
            continue;
          }
        }
      
        map.put(paramName, param.getFromDeque(deque));      
      }
      
      mapList.add(map);
    }
  }
  public Map<String, Object> get(Integer index) throws Exception
  {
    //Long nanoTime = null;
    
    //nanoTime = System.nanoTime();
    
    if(lazySource == null || lazySource.getVersion().intValue() != sourceVersion.intValue())
    {
      initialize();
    }    
    
    if(index >= count)
    {
      throw new IndexOutOfBoundsException("Indeks dla akcesora wykracza poza zakres.");
    }
    
    
    //pApplet.println("                            ACCESSOR: "+String.valueOf(System.nanoTime()-nanoTime));
    
    return mapList.get(index);  
  }
}

public static abstract class ColladaArray<T> extends ColladaPart implements HavingContent<List<T>>
{
  protected Integer count = null;
  protected String id = null;
  protected String name = null;
  protected Integer version = null;
  
  protected List<T> content = new ArrayList<T>();
  protected List<T> newContent = null;
  
  public ColladaArray(PApplet pApplet, XML array, ColladaPart parent, Class<T> type, T empty) throws Exception
  {
    super(pApplet, array, parent);
    
    count = parseAttribute(array, "count", Integer.class);
    id = parseAttribute(array, "id", String.class);
    name = parseAttribute(array, "name", String.class);

    version = 0;    
    
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
  
  public Integer getVersion()
  {
    return version;
  }
  
  private void modified()
  {
    if(version.intValue() == Integer.MAX_VALUE)
    {
      version = 0;
    }
    else
    {
      ++version;
    }    
  }
  
  public void setContent(List<T> newContent)
  {
    this.newContent = newContent; 
    modified();
  }
  
  public void reset()
  {
    newContent = null;
    modified();
  }
  
  public List<T> getContent()
  {
    if(newContent != null)
    {
      return newContent;
    }
    else
    {
      return content;
    }
  } 
}

public static class ColladaBoolArray extends ColladaArray<Boolean>
{
  public ColladaBoolArray(PApplet pApplet, XML boolArray, ColladaPart parent) throws Exception
  {
    super(pApplet, boolArray, parent, Boolean.class, false);
  }
}

public static class ColladaFloatArray extends ColladaArray<Float>
{
  protected Integer digits = null;
  protected Integer magnitude = null;
  
  public ColladaFloatArray(PApplet pApplet, XML floatArray, ColladaPart parent) throws Exception
  {
    super(pApplet, floatArray, parent, Float.class, 0.0);
    
    digits = parseAttribute(floatArray, "digits", Integer.class, 6);
    magnitude = parseAttribute(floatArray, "magnitude", Integer.class, 38);    
  }
}

public static class ColladaIDREFArray extends ColladaArray<String>
{  
  public ColladaIDREFArray(PApplet pApplet, XML idrefArray, ColladaPart parent) throws Exception
  {
    super(pApplet, idrefArray, parent, String.class,"");    
  }
}

public static class ColladaIntArray extends ColladaArray<Integer>
{
  protected Integer minInclusive = null;
  protected Integer maxInclusive = null;
    
  public ColladaIntArray(PApplet pApplet, XML intArray, ColladaPart parent) throws Exception
  {
    super(pApplet, intArray, parent, Integer.class, 0);
    
    minInclusive = parseAttribute(intArray, "minInclusive", Integer.class, -2147483648);
    maxInclusive = parseAttribute(intArray, "maxInclusive", Integer.class, 2147483647);       
  }
}

public static class ColladaNameArray extends ColladaArray<String>
{   
  public ColladaNameArray(PApplet pApplet, XML nameArray, ColladaPart parent) throws Exception
  {
    super(pApplet, nameArray, parent, String.class, "");
  }
}

public static class ColladaParam extends ColladaPart
{
  protected String name = null;
  protected String sid = null;
  protected String type = null;
  protected String semantic = null;
  
  public ColladaParam(PApplet pApplet, XML param, ColladaPart parent) throws Exception
  {
    super(pApplet, param, parent);
    
    name = parseAttribute(param, "name", String.class);
    sid = parseAttribute(param, "sid", String.class);
    type = parseAttribute(param, "type", String.class);
    semantic = parseAttribute(param, "semantic", String.class);
  }
  
  public String getName()
  {
    return name;
  }
  
  public String getType()
  {
    return type;
  }
  
  private <T> T convertTo(Object object, Class<T> type) throws Exception
  {
    if(object.getClass() == type)
    {
      return (T)object;
    }
    else if(Number.class.isAssignableFrom(object.getClass()) && Number.class.isAssignableFrom(type))
    {
      if(type == Byte.class)
      {
        return (T)new Byte(((Number)object).byteValue());
      }
      else if(type == Double.class)
      {
        return (T)new Double(((Number)object).doubleValue());
      }
      else if(type == Float.class)
      {
        return (T)new Float(((Number)object).floatValue());
      }      
      else if(type == Integer.class)
      {
        return (T)new Integer(((Number)object).intValue());
      }      
      else if(type == Long.class)
      {
        return (T)new Long(((Number)object).longValue());
      }      
      else if(type == Short.class)
      {
        return (T)new Short(((Number)object).shortValue());
      }
      else
      {
        throw new Exception("TODO other number conversions");
      }     
    }
    else if(object.getClass() == Boolean.class)
    {
      return (T)Helper.performClass(type, "valueOf", new Class<?>[] {Boolean.TYPE}, new Object[] {object});    
    }
    else
    {
      return (T)Helper.performClass(type, "valueOf", new Class<?>[] {String.class}, new Object[] {String.valueOf(object)});     
    }
  }
  
  public Object getFromDeque(Deque<Object> deque) throws Exception
  {
    if(type.equals("bool"))
    {
      return convertTo(deque.removeFirst(), Boolean.class);
    }
    else if(type.equals("bool2"))
    {
      return new boolean[] {
        convertTo(deque.removeFirst(), Boolean.class),
        convertTo(deque.removeFirst(), Boolean.class)
      };    
    }
    else if(type.equals("bool3"))
    {
      return new boolean[] {
        convertTo(deque.removeFirst(), Boolean.class),
        convertTo(deque.removeFirst(), Boolean.class),        
        convertTo(deque.removeFirst(), Boolean.class)
      };
    }    
    else if(type.equals("bool4"))
    {
      return new boolean[] {
        convertTo(deque.removeFirst(), Boolean.class),
        convertTo(deque.removeFirst(), Boolean.class),
        convertTo(deque.removeFirst(), Boolean.class),        
        convertTo(deque.removeFirst(), Boolean.class)
      };
    }
    else if(type.equals("float"))
    {
      return convertTo(deque.removeFirst(), Float.class);       
    }
    else if(type.equals("float2"))
    {
      return new float[] {
        convertTo(deque.removeFirst(), Float.class),
        convertTo(deque.removeFirst(), Float.class)
      };            
    }
    else if(type.equals("float2x2"))
    {
      return new float[][] {
        new float[] { convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class) },
        new float[] { convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class) }
      };            
    }
    else if(type.equals("float2x3"))
    {
      return new float[][] {
        new float[] { convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class) },
        new float[] { convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class) }
      };            
    }
    else if(type.equals("float2x4"))
    {
      return new float[][] {
        new float[] { convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class) },
        new float[] { convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class) }
      };            
    }
    else if(type.equals("float3"))
    {
      return new float[] {
        convertTo(deque.removeFirst(), Float.class),
        convertTo(deque.removeFirst(), Float.class),        
        convertTo(deque.removeFirst(), Float.class)
      };            
    }
    else if(type.equals("float3x2"))
    {
      return new float[][] {
        new float[] { convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class) },
        new float[] { convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class) },        
        new float[] { convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class) }
      };            
    }
    else if(type.equals("float3x3"))
    {
      return new float[][] {
        new float[] { convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class) },
        new float[] { convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class) },        
        new float[] { convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class) }
      };            
    }
    else if(type.equals("float3x4"))
    {
      return new float[][] {
        new float[] { convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class) },
        new float[] { convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class) },        
        new float[] { convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class) }
      };            
    }
    else if(type.equals("float4"))
    {
      return new float[] {
        convertTo(deque.removeFirst(), Float.class),
        convertTo(deque.removeFirst(), Float.class),
        convertTo(deque.removeFirst(), Float.class),        
        convertTo(deque.removeFirst(), Float.class)
      };            
    }
    else if(type.equals("float4x2"))
    {
      return new float[][] {
        new float[] { convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class) },
        new float[] { convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class) },
        new float[] { convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class) },        
        new float[] { convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class) }
      };            
    }
    else if(type.equals("float4x3"))
    {
      return new float[][] {
        new float[] { convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class) },
        new float[] { convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class) },
        new float[] { convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class) },        
        new float[] { convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class) }
      };            
    }
    else if(type.equals("float4x4"))
    {
      return new float[][] {
        new float[] { convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class) },
        new float[] { convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class) },
        new float[] { convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class) },        
        new float[] { convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class), convertTo(deque.removeFirst(), Float.class) }
      };            
    }   
    else if(type.equals("float7"))
    {
      return new float[] {
        convertTo(deque.removeFirst(), Float.class),
        convertTo(deque.removeFirst(), Float.class),
        convertTo(deque.removeFirst(), Float.class),        
        convertTo(deque.removeFirst(), Float.class),
        convertTo(deque.removeFirst(), Float.class),
        convertTo(deque.removeFirst(), Float.class),        
        convertTo(deque.removeFirst(), Float.class)
      };            
    }  
    else if(type.equals("int"))
    {
      return convertTo(deque.removeFirst(), Integer.class);       
    }
    else if(type.equals("int2"))
    {
      return new int[] {
        convertTo(deque.removeFirst(), Integer.class),
        convertTo(deque.removeFirst(), Integer.class)
      };            
    }
    else if(type.equals("int2x2"))
    {
      return new int[][] {
        new int[] { convertTo(deque.removeFirst(), Integer.class), convertTo(deque.removeFirst(), Integer.class) },
        new int[] { convertTo(deque.removeFirst(), Integer.class), convertTo(deque.removeFirst(), Integer.class) }
      };            
    }    
    else if(type.equals("int3"))
    {
      return new int[] {
        convertTo(deque.removeFirst(), Integer.class),
        convertTo(deque.removeFirst(), Integer.class),        
        convertTo(deque.removeFirst(), Integer.class)
      };            
    }  
    else if(type.equals("int3x3"))
    {
      return new int[][] {
        new int[] { convertTo(deque.removeFirst(), Integer.class), convertTo(deque.removeFirst(), Integer.class), convertTo(deque.removeFirst(), Integer.class) },
        new int[] { convertTo(deque.removeFirst(), Integer.class), convertTo(deque.removeFirst(), Integer.class), convertTo(deque.removeFirst(), Integer.class) },        
        new int[] { convertTo(deque.removeFirst(), Integer.class), convertTo(deque.removeFirst(), Integer.class), convertTo(deque.removeFirst(), Integer.class) }
      };            
    }    
    else if(type.equals("int4"))
    {
      return new int[] {
        convertTo(deque.removeFirst(), Integer.class),
        convertTo(deque.removeFirst(), Integer.class),
        convertTo(deque.removeFirst(), Integer.class),        
        convertTo(deque.removeFirst(), Integer.class)
      };            
    }    
    else if(type.equals("int4x4"))
    {
      return new int[][] {
        new int[] { convertTo(deque.removeFirst(), Integer.class), convertTo(deque.removeFirst(), Integer.class), convertTo(deque.removeFirst(), Integer.class), convertTo(deque.removeFirst(), Integer.class) },
        new int[] { convertTo(deque.removeFirst(), Integer.class), convertTo(deque.removeFirst(), Integer.class), convertTo(deque.removeFirst(), Integer.class), convertTo(deque.removeFirst(), Integer.class) },
        new int[] { convertTo(deque.removeFirst(), Integer.class), convertTo(deque.removeFirst(), Integer.class), convertTo(deque.removeFirst(), Integer.class), convertTo(deque.removeFirst(), Integer.class) },        
        new int[] { convertTo(deque.removeFirst(), Integer.class), convertTo(deque.removeFirst(), Integer.class), convertTo(deque.removeFirst(), Integer.class), convertTo(deque.removeFirst(), Integer.class) }
      };            
    }     
    else if(type.equals("name") || type.equals("Name") || type.equals("string"))
    {
      return convertTo(deque.removeFirst(), String.class);
    }
    else if(type.equals("double"))
    {
      return convertTo(deque.removeFirst(), Double.class); 
    }
    else
    {
      throw new Exception("TODO implementation of type: "+type);
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
  
  public ColladaSource(PApplet pApplet, XML source, ColladaPart parent) throws Exception
  {
    super(pApplet, source, parent);
    
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
  
  public Integer getCount()
  {
    return ((ColladaTechniqueCommonInSource)this.getTechnique()).getCount();    
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
  
  public ColladaInput(PApplet pApplet, XML input, ColladaPart parent) throws Exception
  {
    super(pApplet, input, parent);
    
    offset = parseAttribute(input, "offset", Integer.class);
    semantic = parseAttribute(input, "semantic", String.class);
    source = parseAttribute(input, "source", String.class);
    set = parseAttribute(input, "set", Integer.class);
  }
  
  public ColladaSource getSource()
  {
    return (ColladaSource)getByURL(source);
  }
  
  public Integer getCount() throws Exception
  {
    ColladaPart part = getByURL(source);
    if(part.getClass() == ColladaSource.class)
    {
      return ((ColladaSource)part).getCount();
    }
    else if(part.getClass() == ColladaVertices.class)
    {
      return ((ColladaVertices)part).getCount();
    }
    else
    {
      throw new Exception("TODO ColladaInput->getCount()");
    }    
  }
  
  public Map<String, Map<String, Object>> getUsingInput(Integer index) throws Exception
  {
    //Long nanoTime = null;
    
    //nanoTime = System.nanoTime();
    
    ColladaPart part = getByURL(source);
    if(part.getClass() == ColladaSource.class)
    {
      
      Map<String, Map<String, Object>> map = new HashMap<String, Map<String, Object>>();
      map.put(semantic,((ColladaSource)part).getUsingTechnique(index));
      //pApplet.println("                  input s draw: "+String.valueOf(System.nanoTime()-nanoTime));       
      return map;
    }
    else if(part.getClass() == ColladaVertices.class)
    {
      Map<String, Map<String, Object>> map = ((ColladaVertices)part).getUsingVertices(index); 
      //pApplet.println("                  input v draw: "+String.valueOf(System.nanoTime()-nanoTime));       
      return map;
    }
    else
    {
      throw new Exception("TODO ColladaInput->getUsingInput(...)");
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
 
  public ColladaExtra(PApplet pApplet, XML extra, ColladaPart parent) throws Exception
  {
    super(pApplet, extra, parent);
    id = parseAttribute(extra, "id", String.class);
    name = parseAttribute(extra, "name", String.class);
    type = parseAttribute(extra, "type", String.class);
    
    asset = parseChild(extra, "asset", ColladaAsset.class);
    parseChildren(extra, "technique", ColladaTechnique.class, techniqueList);
  }
}

public static abstract class ColladaAbstractTechnique extends ColladaPart
{
  public ColladaAbstractTechnique(PApplet pApplet, XML abstractTechnique, ColladaPart parent) throws Exception
  {
    super(pApplet, abstractTechnique, parent);
  }
}

public static class ColladaTechnique extends ColladaAbstractTechnique
{
  protected String profile = null;
  protected String xmlns = null;  
  
  public ColladaTechnique(PApplet pApplet, XML technique, ColladaPart parent) throws Exception
  {
    super(pApplet, technique, parent);
    profile = parseAttribute(technique, "profile", String.class);
    xmlns = parseAttribute(technique, "xmlns", String.class);
  }
}

public static class ColladaTechniqueCommon extends ColladaAbstractTechnique
{
  public ColladaTechniqueCommon(PApplet pApplet, XML techniqueCommon, ColladaPart parent) throws Exception
  {
    super(pApplet, techniqueCommon, parent);
  }
}

public static class ColladaTechniqueCommonInBindMaterial extends ColladaTechniqueCommon 
{
  public ColladaTechniqueCommonInBindMaterial(PApplet pApplet, XML techniqueCommonInBindMaterial, ColladaPart parent) throws Exception
  {
    super(pApplet, techniqueCommonInBindMaterial, parent);
    PApplet.println("TODO ColladaTechniqueCommonInBindMaterial");
  }
}

public static class ColladaTechniqueCommonInInstanceRigidBody extends ColladaTechniqueCommon 
{
  public ColladaTechniqueCommonInInstanceRigidBody(PApplet pApplet, XML techniqueCommonInInstanceRigidBody, ColladaPart parent) throws Exception
  {
    super(pApplet, techniqueCommonInInstanceRigidBody, parent);
    PApplet.println("TODO ColladaTechniqueCommonInInstanceRigidBody");
  }
}

public static class ColladaTechniqueCommonInLight extends ColladaTechniqueCommon 
{
  public ColladaTechniqueCommonInLight(PApplet pApplet, XML techniqueCommonInLight, ColladaPart parent) throws Exception
  {
    super(pApplet, techniqueCommonInLight, parent);
    PApplet.println("TODO ColladaTechniqueCommonInLight");
  }
}

public static class ColladaTechniqueCommonInOptics extends ColladaTechniqueCommon 
{
  public ColladaTechniqueCommonInOptics(PApplet pApplet, XML techniqueCommonInOptics, ColladaPart parent) throws Exception
  {
    super(pApplet, techniqueCommonInOptics, parent);
    PApplet.println("TODO ColladaTechniqueCommonInOptics");
  }
}

public static class ColladaTechniqueCommonInPhysicsMaterial extends ColladaTechniqueCommon 
{
  public ColladaTechniqueCommonInPhysicsMaterial(PApplet pApplet, XML techniqueCommonInPhysicsMaterial, ColladaPart parent) throws Exception
  {
    super(pApplet, techniqueCommonInPhysicsMaterial, parent);
    PApplet.println("TODO ColladaTechniqueCommonInPhysicsMaterial");
  }
}

public static class ColladaTechniqueCommonInPhysicsScene extends ColladaTechniqueCommon 
{
  public ColladaTechniqueCommonInPhysicsScene(PApplet pApplet, XML techniqueCommonInPhysicsScene, ColladaPart parent) throws Exception
  {
    super(pApplet, techniqueCommonInPhysicsScene, parent);
    PApplet.println("TODO ColladaTechniqueCommonInPhysicsScene");
  }
}

public static class ColladaTechniqueCommonInRigidBody extends ColladaTechniqueCommon 
{
  public ColladaTechniqueCommonInRigidBody(PApplet pApplet, XML techniqueCommonInRigidBody, ColladaPart parent) throws Exception
  {
    super(pApplet, techniqueCommonInRigidBody, parent);
    PApplet.println("TODO ColladaTechniqueCommonInRigidBody");
  }
}

public static class ColladaTechniqueCommonInRigidConstraint extends ColladaTechniqueCommon 
{
  public ColladaTechniqueCommonInRigidConstraint(PApplet pApplet, XML techniqueCommonInRigidConstraint, ColladaPart parent) throws Exception
  {
    super(pApplet, techniqueCommonInRigidConstraint, parent);
    PApplet.println("TODO ColladaTechniqueCommonInRigidConstraint");
  }
}

public static class ColladaTechniqueCommonInSource extends ColladaTechniqueCommon 
{
  protected ColladaAccessor accessor = null;
  
  public ColladaTechniqueCommonInSource(PApplet pApplet, XML techniqueCommonInSource, ColladaPart parent) throws Exception
  {
    super(pApplet, techniqueCommonInSource, parent);
    
    accessor = parseChild(techniqueCommonInSource, "accessor", ColladaAccessor.class);
  }
  
  public ColladaAccessor getAccessor()
  {
    return accessor;
  }
  
  public Integer getCount()
  {
    return this.getAccessor().getCount();
  }
  
  public Map<String, Object> getUsingAccessor(Integer index) throws Exception
  {
    return this.getAccessor().get(index);
  }
}

/* Geometry */

public static class ColladaControlVertices extends ColladaPart
{
  public ColladaControlVertices(PApplet pApplet, XML controlVertices, ColladaPart parent) throws Exception
  {
    super(pApplet, controlVertices, parent);
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
  
  public ColladaGeometry(PApplet pApplet, XML geometry, ColladaPart parent) throws Exception
  {
    super(pApplet, geometry, parent);
    
    id = parseAttribute(geometry, "id", String.class);
    name = parseAttribute(geometry, "name", String.class);
    
    asset = parseChild(geometry, "asset", ColladaAsset.class);
    //convexMesh = parseChild(geometry, "convex_mesh", ColladaConvexMesh.class);
    mesh = parseChild(geometry, "mesh", ColladaMesh.class);
    spline = parseChild(geometry, "spline", ColladaSpline.class);
    parseChildren(geometry, "extra", ColladaExtra.class, extraList);
  }
  
  public ColladaMesh getMesh()
  {
    return mesh;
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
  
  public ColladaInstanceGeometry(PApplet pApplet, XML instanceGeometry, ColladaPart parent) throws Exception
  {
    super(pApplet, instanceGeometry, parent);
    
    sid = parseAttribute(instanceGeometry,"sid",String.class);
    name = parseAttribute(instanceGeometry,"name",String.class);
    url = parseAttribute(instanceGeometry,"url",String.class);
    
    //bindMaterial = parseChild(instanceGeometry, "bind_material", ColladaBindMaterial.class);
    parseChildren(instanceGeometry, "extra", ColladaExtra.class, extraList);
  }
  
  public void draw() throws Exception
  {
    ((ColladaGeometry)getByURL(url)).draw();
  }
}

public static class ColladaLibraryGeometries extends ColladaLibrary
{
  protected String id = null;
  protected String name = null;
  
  protected ColladaAsset asset = null;
  protected List<ColladaGeometry> geometryList = new ArrayList<ColladaGeometry>();
  protected List<ColladaExtra> extraList = new ArrayList<ColladaExtra>();
  
  public ColladaLibraryGeometries(PApplet pApplet, XML libraryGeometries, ColladaPart parent) throws Exception
  {
    super(pApplet, libraryGeometries, parent);
    
    id = parseAttribute(libraryGeometries, "id", String.class);
    name = parseAttribute(libraryGeometries, "name", String.class);
    
    asset = parseChild(libraryGeometries, "asset", ColladaAsset.class);
    parseChildren(libraryGeometries, "geometry", ColladaGeometry.class, geometryList);
    parseChildren(libraryGeometries, "extra", ColladaExtra.class, extraList);
  }
}

public static class ColladaLines extends ColladaPart
{
  public ColladaLines(PApplet pApplet, XML lines, ColladaPart parent) throws Exception
  {
    super(pApplet, lines, parent);
    PApplet.println("TODO ColladaLines");
  }
}

public static class ColladaLineStrips extends ColladaPart
{
  public ColladaLineStrips(PApplet pApplet, XML lineStrips, ColladaPart parent) throws Exception
  {
    super(pApplet, lineStrips, parent);
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
  
  public ColladaMesh(PApplet pApplet, XML mesh, ColladaPart parent) throws Exception
  {
    super(pApplet, mesh, parent);
    
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
  
  public ColladaVertices getVertices()
  {
    return vertices;
  }
  
  public ColladaTriangles getTriangles()
  {
    return trianglesList.get(0);
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
  
  public ColladaP(PApplet pApplet, XML p, ColladaPart parent) throws Exception
  {
    super(pApplet, p, parent);
    
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
  public ColladaPolygons(PApplet pApplet, XML polygons, ColladaPart parent) throws Exception
  {
    super(pApplet, polygons, parent);
    PApplet.println("TODO ColladaPolygons");
  }
}

public static class ColladaPolyList extends ColladaPart
{
  public ColladaPolyList(PApplet pApplet, XML polyList, ColladaPart parent) throws Exception
  {
    super(pApplet, polyList, parent);
    PApplet.println("TODO ColladaPolyList");
  }
}

public static class ColladaSpline extends ColladaPart
{
  public ColladaSpline(PApplet pApplet, XML spline, ColladaPart parent) throws Exception
  {
    super(pApplet, spline, parent);
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
  protected PImage image = null;
  protected PImage newImage = null;
  
  public ColladaTriangles(PApplet pApplet, XML triangles, ColladaPart parent) throws Exception
  {
    super(pApplet, triangles, parent);
    
    name = parseAttribute(triangles, "name", String.class);
    count = parseAttribute(triangles, "count", Integer.class);
    material = parseAttribute(triangles, "material", String.class);
    
    parseChildren(triangles, "input", ColladaInput.class, inputList);
    p = parseChild(triangles, "p", ColladaP.class);
    parseChildren(triangles, "extra", ColladaExtra.class, extraList);
    
    image = pApplet.loadImage("tekstura.png");
    
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
    //Long time = System.currentTimeMillis();    
    
    pApplet.beginShape(pApplet.TRIANGLES);
    
    if(newImage != null)
    {
      pApplet.texture(newImage);
    }
    else
    {
      pApplet.texture(image);
    }
    
    //pApplet.println("    1 mesh draw: "+String.valueOf(System.currentTimeMillis()-time));    
    
    List<Integer> t = p.getContent();
    
    Map<String, Map<String, Object>> map = new HashMap<String, Map<String, Object>>();

    //pApplet.println("    2 mesh draw: "+String.valueOf(System.currentTimeMillis()-time));       

    //Long nanoTime = null;
    //Long nanoTime2 = null;
    
    for(Integer triangleIndex = 0; triangleIndex < count; ++triangleIndex)
    { 
      for(Integer vertexIndex = 0; vertexIndex < 3; ++vertexIndex)
      {
        
        //nanoTime = System.nanoTime();
        
        for(Integer offset = 0; offset <= maxOffset; ++offset)
        {
          //nanoTime2 = System.nanoTime();
          
          ColladaInput input = inputMap.get(offset);
          if(input.getSemantic().equals("COLOR")) // OPTYMALIZACJA
          {
            continue;
          }
          
          if(input == null)
          {
            continue;
          }
          
          //pApplet.println("              1 looop mesh draw: "+String.valueOf(System.nanoTime()-nanoTime2));
          //nanoTime2 = System.nanoTime();
          
          map.putAll(input.getUsingInput(t.get(triangleIndex*3*(maxOffset+1) + vertexIndex*(maxOffset+1) + offset)));
          
          //pApplet.println("              2 looop mesh draw: "+String.valueOf(System.nanoTime()-nanoTime2));
        }
        
        //pApplet.println("        1 loop mesh draw: "+String.valueOf(System.nanoTime()-nanoTime));
        //nanoTime = System.nanoTime();        
        pApplet.normal((Float)map.get("NORMAL").get("X"), (Float)map.get("NORMAL").get("Y"), (Float)map.get("NORMAL").get("Z"));
        pApplet.vertex((Float)map.get("POSITION").get("X"), (Float)map.get("POSITION").get("Y"), (Float)map.get("POSITION").get("Z"), (Float)map.get("TEXCOORD").get("S"), 1.0-(Float)map.get("TEXCOORD").get("T"));
        //pApplet.println("        2 loop mesh draw: "+String.valueOf(System.nanoTime()-nanoTime));
        
      }      
    }
    
    //pApplet.println("    3 mesh draw: "+String.valueOf(System.currentTimeMillis()-time));      
    
    pApplet.endShape(); 
    
    //pApplet.println("    mesh draw: "+String.valueOf(System.currentTimeMillis()-time));    
  }
  
  public void setImage(PImage img)
  {
    newImage = img;
  }
  
  public void resetImage()
  {
    newImage = null;
  }
  
  public ColladaSource getTexcoordSource() throws Exception
  {
    for(ColladaInput input : inputList)
    {
      if(input.getSemantic().equals("TEXCOORD"))
      {
        return input.getSource();
      }
    }
    throw new Exception("Position input not found");
  }
  
}

public static class ColladaTriFans extends ColladaPart
{
  public ColladaTriFans(PApplet pApplet, XML triFans, ColladaPart parent) throws Exception
  {
    super(pApplet, triFans, parent);
    PApplet.println("TODO ColladaTriFans");
  }
}

public static class ColladaTriStrips extends ColladaPart
{
  public ColladaTriStrips(PApplet pApplet, XML triStrips, ColladaPart parent) throws Exception
  {
    super(pApplet, triStrips, parent);
    PApplet.println("TODO ColladaTriStrips");
  }
}

public static class ColladaVertices extends ColladaPart
{
  protected String id = null;
  protected String name = null;
  
  protected List<ColladaInput> inputList = new ArrayList<ColladaInput>();
  protected List<ColladaExtra> extraList = new ArrayList<ColladaExtra>();
  
  public ColladaVertices(PApplet pApplet, XML vertices, ColladaPart parent) throws Exception
  {
    super(pApplet, vertices, parent);
    
    id = parseAttribute(vertices, "id", String.class);
    name = parseAttribute(vertices, "name", String.class);
    
    parseChildren(vertices, "input", ColladaInput.class, inputList);
    parseChildren(vertices, "extra", ColladaExtra.class, extraList);
  }
  
  public ColladaSource getPositionsSource() throws Exception
  {
    for(ColladaInput input : inputList)
    {
      if(input.getSemantic().equals("POSITION"))
      {
        return input.getSource();
      }
    }
    throw new Exception("Position input not found");
  }
  
  public Integer getCount() throws Exception
  {
    ColladaInput positions = null;
    for(ColladaInput input : inputList)
    {
      if(input.getSemantic().equals("POSITIONS"))
      {
        positions = input;
        break;
      }
    }
    return positions.getCount();
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
  public ColladaAmbient(PApplet pApplet, XML ambient, ColladaPart parent) throws Exception
  {
    super(pApplet, ambient, parent);
    PApplet.println("TODO ColladaAmbient");
  }
}

public static class ColladaColor extends ColladaPart
{
  public ColladaColor(PApplet pApplet, XML kolor, ColladaPart parent) throws Exception
  {
    super(pApplet, kolor, parent);
    PApplet.println("TODO ColladaColor");
  }
}

public static class ColladaDirectional extends ColladaPart
{
  public ColladaDirectional(PApplet pApplet, XML directional, ColladaPart parent) throws Exception
  {
    super(pApplet, directional, parent);
    PApplet.println("TODO ColladaDirectional");
  }
}

public static class ColladaInstanceLight extends ColladaPart
{
  public ColladaInstanceLight(PApplet pApplet, XML instanceLight, ColladaPart parent) throws Exception
  {
    super(pApplet, instanceLight, parent);
    PApplet.println("TODO ColladaInstanceLight");
  }
}

public static class ColladaLibraryLights extends ColladaLibrary
{
  public ColladaLibraryLights(PApplet pApplet, XML libraryLights, ColladaPart parent) throws Exception
  {
    super(pApplet, libraryLights, parent);
    PApplet.println("TODO ColladaLibraryLights");
  }
}

public static class ColladaLight extends ColladaPart
{
  public ColladaLight(PApplet pApplet, XML light, ColladaPart parent) throws Exception
  {
    super(pApplet, light, parent);
    PApplet.println("TODO ColladaLight");
  }
}

public static class ColladaPoint extends ColladaPart
{
  public ColladaPoint(PApplet pApplet, XML point, ColladaPart parent) throws Exception
  {
    super(pApplet, point, parent);
    PApplet.println("TODO ColladaPoint");
  }
}

public static class ColladaSpot extends ColladaPart
{
  public ColladaSpot(PApplet pApplet, XML spot, ColladaPart parent) throws Exception
  {
    super(pApplet, spot, parent);
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
  
  public ColladaAsset(PApplet pApplet, XML asset, ColladaPart parent) throws Exception
  {
    super(pApplet, asset, parent);
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
  
  public ColladaAuthor(PApplet pApplet, XML author, ColladaPart parent) throws Exception
  {
    super(pApplet, author, parent);
    content = author.getContent();
  }
}

public static class ColladaAuthoringTool extends ColladaPart
{
  protected String content = null;
  
  public ColladaAuthoringTool(PApplet pApplet, XML authoringTool, ColladaPart parent) throws Exception
  {
    super(pApplet, authoringTool, parent);
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
  
  public Collada(PApplet pApplet, XML collada, ColladaPart parent) throws Exception
  { 
    super(pApplet, collada, parent);
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
  
  public void run() throws Exception
  {
    for(ColladaLibraryAnimations libraryAnimations : libraryAnimationsList)
    {
      libraryAnimations.run();
    }
  }
}

public static class ColladaComments extends ColladaPart
{
  protected String content = null;
  
  public ColladaComments(PApplet pApplet, XML comments, ColladaPart parent) throws Exception
  {
    super(pApplet, comments, parent);
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
  
  public ColladaContributor(PApplet pApplet, XML contributor, ColladaPart parent) throws Exception
  {
    super(pApplet, contributor, parent);
    author = parseChild(contributor, "author", ColladaAuthor.class);
    authoringTool = parseChild(contributor, "authoring_tool", ColladaAuthoringTool.class);
    comments = parseChild(contributor, "comments", ColladaComments.class);
    copyright = parseChild(contributor, "copyright", ColladaCopyright.class);
    sourceData = parseChild(contributor, "source_data", ColladaSourceData.class);
  }
}

public static class ColladaCopyright extends ColladaPart
{
  public ColladaCopyright(PApplet pApplet, XML copyright, ColladaPart parent) throws Exception
  {
    super(pApplet, copyright, parent);
    PApplet.println("TODO ColladaCopyright");
  }
}

public static class ColladaCreated extends ColladaPart
{
  protected String content = null;
  
  public ColladaCreated(PApplet pApplet, XML created, ColladaPart parent) throws Exception
  {
    super(pApplet, created, parent);
    content = created.getContent();
  }
}

public static class ColladaKeywords extends ColladaPart
{
  protected String content = null;
  
  public ColladaKeywords(PApplet pApplet, XML keywords, ColladaPart parent) throws Exception
  {
    super(pApplet, keywords, parent);
    content = keywords.getContent();
  }
}

public static class ColladaModified extends ColladaPart
{
  protected String content = null;
  
  public ColladaModified(PApplet pApplet, XML modified, ColladaPart parent) throws Exception
  {
    super(pApplet, modified, parent);
    content = modified.getContent();
  }
}

public static class ColladaRevision extends ColladaPart
{
  protected String content = null;
  
  public ColladaRevision(PApplet pApplet, XML revision, ColladaPart parent) throws Exception
  {
    super(pApplet, revision, parent);
    content = revision.getContent();
  }
}

public static class ColladaSourceData extends ColladaPart
{
  public ColladaSourceData(PApplet pApplet, XML sourceData, ColladaPart parent) throws Exception
  {
    super(pApplet, sourceData, parent);
    PApplet.println("TODO ColladaSourceData");
  }
}

public static class ColladaSubject extends ColladaPart
{
  protected String content = null;
  
  public ColladaSubject(PApplet pApplet, XML subject, ColladaPart parent) throws Exception
  {
    super(pApplet, subject, parent);
    content = subject.getContent();
  }
}

public static class ColladaTitle extends ColladaPart
{
  protected String content = null;
  
  public ColladaTitle(PApplet pApplet, XML title, ColladaPart parent) throws Exception
  {
    super(pApplet, title, parent);
    content = title.getContent();
  }
}

public static class ColladaUnit extends ColladaPart
{
  protected String name = null;
  protected Float meter = null;
  
  public ColladaUnit(PApplet pApplet, XML unit, ColladaPart parent) throws Exception
  {
    super(pApplet, unit, parent);
    name = parseAttribute(unit, "name", String.class, "meter");
    meter = parseAttribute(unit, "meter", Float.class, 1.0);
  }
}

public static class ColladaUpAxis extends ColladaPart
{
  protected String content = "Y_UP";
  
  public ColladaUpAxis(PApplet pApplet, XML upAxis, ColladaPart parent) throws Exception
  {
    super(pApplet, upAxis, parent);
    content = upAxis.getContent();
  }
}

/* Scene */

public static class ColladaEvaluateScene extends ColladaPart
{
  protected String name = null;
  //protected List<ColladaRender> renderList = new ArrayList<ColladaRender>();
  
  public ColladaEvaluateScene(PApplet pApplet, XML evaluateScene, ColladaPart parent) throws Exception
  {
    super(pApplet, evaluateScene, parent);
    
    name = parseAttribute(evaluateScene, "name", String.class);
  }
}

public static class ColladaInstanceNode extends ColladaPart
{
  public ColladaInstanceNode(PApplet pApplet, XML instanceNode, ColladaPart parent) throws Exception
  {
    super(pApplet, instanceNode, parent);
    PApplet.println("TODO ColladaInstanceNode");
  }
}

public static class ColladaInstanceVisualScene extends ColladaPart
{
  protected String sid = null;
  protected String name = null;
  protected String url = null;
  
  public ColladaInstanceVisualScene(PApplet pApplet, XML instanceVisualScene, ColladaPart parent) throws Exception
  {
    super(pApplet, instanceVisualScene, parent);
    sid = parseAttribute(instanceVisualScene, "sid", String.class);
    name = parseAttribute(instanceVisualScene, "name", String.class);
    url = parseAttribute(instanceVisualScene, "url", String.class);
  }
  
  public void draw() throws Exception
  {
    ((ColladaVisualScene)getByURL(url)).draw();
  }
}

public static class ColladaLibraryNodes extends ColladaLibrary
{
  public ColladaLibraryNodes(PApplet pApplet, XML libraryNodes, ColladaPart parent) throws Exception
  {
    super(pApplet, libraryNodes, parent);
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
  
  public ColladaLibraryVisualScenes(PApplet pApplet, XML libraryVisualScenes, ColladaPart parent) throws Exception
  {
    super(pApplet, libraryVisualScenes, parent);
    
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
  
  protected ColladaNode parent = null;
  
  public ColladaNode(PApplet pApplet, XML node, ColladaNode parent) throws Exception
  {
    super(pApplet, node, parent);
    this.parent = parent;
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
    parseChildren(node, "extra", ColladaExtra.class, extraList);
    
    /*
    float mat[][] = getMatrix();
    pApplet.println("---------------------------");
    for(Integer i = 0; i < 4; ++i)
    {
      StringBuffer buffer = new StringBuffer();
      for(Integer j = 0; j < 4; ++j)
      {
        buffer.append(String.valueOf(mat[i][j])+" ");
      }
      pApplet.println(buffer.toString());
    }
    pApplet.println("---------------------------");
    */
    
    parseChildren(node, "node", ColladaNode.class, new Class<?>[] {ColladaNode.class}, new Object[] {this}, nodeList);
  }
  
  public float[][] getMatrix()
  {
    float[][] m = Mat.identity(4);
    
    for(ColladaMatrix matrix : matrixList)
    {
      m = Mat.multiply(m, matrix.getContent());
    }
    
    if(parent == null)
    {
      return m;
    }
    else
    {
      return Mat.multiply(parent.getMatrix(), m); 
    }
  }
  
  public void draw() throws Exception
  {
    pApplet.pushMatrix();
    if(type != null && type.equals("JOINT"))
    {
      //pApplet.sphere(1);
    }
    for(ColladaMatrix matrix : matrixList)
    {
      float[][] m = matrix.getContent();
      pApplet.applyMatrix(
        m[0][0], m[0][1], m[0][2], m[0][3],
        m[1][0], m[1][1], m[1][2], m[1][3],
        m[2][0], m[2][1], m[2][2], m[2][3],
        m[3][0], m[3][1], m[3][2], m[3][3]
      ); 
    }
    if(type != null && type.equals("JOINT"))
    {
      //pApplet.sphere(1);
    }
    for(ColladaInstanceGeometry instanceGeometry : instanceGeometryList)
    {
      instanceGeometry.draw();
    }
    for(ColladaInstanceController instanceController : instanceControllerList)
    {
      instanceController.draw();
    }
    for(ColladaNode node : nodeList)
    {
      node.draw();
    }
    pApplet.popMatrix();
  }
}

public static class ColladaScene extends ColladaPart
{
  //protected List<ColladaInstancePhysicsScene> instancePhysicsSceneList = new ArrayList<ColladaInstancePhysicsScene>();
  protected ColladaInstanceVisualScene instanceVisualScene = null;
  protected List<ColladaExtra> extraList = new ArrayList<ColladaExtra>();
  
  public ColladaScene(PApplet pApplet, XML scene, ColladaPart parent) throws Exception
  {
    super(pApplet, scene, parent);
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
  
  public ColladaVisualScene(PApplet pApplet, XML visualScene, ColladaPart parent) throws Exception
  {
    super(pApplet, visualScene, parent);
    id = parseAttribute(visualScene, "id", String.class);
    name = parseAttribute(visualScene, "name", String.class);
    
    asset = parseChild(visualScene, "asset", ColladaAsset.class);
    parseChildren(visualScene, "node", ColladaNode.class, new Class<?>[] {ColladaNode.class}, new Object[] {null}, nodeList);
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
  public ColladaLookAt(PApplet pApplet, XML lookAt, ColladaPart parent) throws Exception
  {
    super(pApplet, lookAt, parent);
    PApplet.println("TODO ColladaLookAt");
  }
}

public static class ColladaMatrix extends ColladaPart implements HavingContent<float[][]>
{
  protected String sid = null;
  protected float[][] content = new float[4][4];
  
  protected float[][] newContent = null;
  protected Integer version = null;  
  
  public ColladaMatrix(PApplet pApplet, XML matrix, ColladaPart parent) throws Exception
  {
    super(pApplet, matrix, parent);
    
    sid = parseAttribute(matrix, "sid", String.class);
    
    version = 0; 
    
    Integer i = 0;
    Integer j = 0;
    for(String value : matrix.getContent().split("\\s+"))
    {
      if(value.length() > 0)
      {
        content[i][j] = Float.valueOf(value);
        if(++j >= 4)
        {
          j = 0;
          ++i;
        }
      }
    }
  }
  
  public Integer getVersion()
  {
    return version;
  }
  
  private void modified()
  {
    if(version.intValue() == Integer.MAX_VALUE)
    {
      version = 0;
    }
    else
    {
      ++version;
    }    
  }  
  
  public void setContent(float[][] newContent)
  {
    this.newContent = newContent;
    modified();
  }
  
  public void reset()
  {
    newContent = null;
    modified();
  }
  
  public float[][] getContent()
  {
    if(newContent != null)
    {      
      return newContent;
    }
    else
    {
      return content;      
    }
  }
  
}

public static class ColladaRotate extends ColladaPart
{
  public ColladaRotate(PApplet pApplet, XML rotate, ColladaPart parent) throws Exception
  {
    super(pApplet, rotate, parent);
    PApplet.println("TODO ColladaRotate");
  }
}

public static class ColladaScale extends ColladaPart
{
  public ColladaScale(PApplet pApplet, XML scale, ColladaPart parent) throws Exception
  {
    super(pApplet, scale, parent);
    PApplet.println("TODO ColladaScale");
  }
}

public static class ColladaSkew extends ColladaPart
{
  public ColladaSkew(PApplet pApplet, XML skew, ColladaPart parent) throws Exception
  {
    super(pApplet, skew, parent);
    PApplet.println("TODO ColladaSkew");
  }
}

public static class ColladaTranslate extends ColladaPart
{
  public ColladaTranslate(PApplet pApplet, XML translate, ColladaPart parent) throws Exception
  {
    super(pApplet, translate, parent);
    PApplet.println("TODO ColladaTranslate");
  }
}
