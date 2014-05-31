import java.util.Collection;
import java.util.List;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Map;
import java.util.HashMap;
import papaya.Mat;

public static abstract class ColladaPart
{
  private static Map<String, ColladaPart> idMap = new HashMap<String, ColladaPart>();
  
  protected ColladaPart(XML element)
  {
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
      return type.getConstructor(XML.class).newInstance(child);
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
      collection.add(type.getConstructor(XML.class).newInstance(child));
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
      return type.getConstructor(String.class).newInstance(attribute);
    }
    else
    {
      return def;
    }
  }
  
}

/* Animation */

public static class ColladaAnimation extends ColladaPart
{
  public ColladaAnimation(XML animation) throws Exception
  {
    super(animation);
    PApplet.println("TODO ColladaAnimation");
  }
}

public static class ColladaAnimationClip extends ColladaPart
{
  public ColladaAnimationClip(XML animationClip) throws Exception
  {
    super(animationClip);
    PApplet.println("TODO ColladaAnimationClip");
  }
}

public static class ColladaChannel extends ColladaPart
{
  public ColladaChannel(XML channel) throws Exception
  {
    super(channel);
    PApplet.println("TODO ColladaChannel");
  }
}

public static class ColladaInstanceAnimation extends ColladaPart
{
  public ColladaInstanceAnimation(XML instanceAnimation) throws Exception
  {
    super(instanceAnimation);
    PApplet.println("TODO ColladaInstanceAnimation");
  }
}

public static class ColladaLibraryAnimationClips extends ColladaPart
{
  public ColladaLibraryAnimationClips(XML libraryAnimationClips) throws Exception
  {
    super(libraryAnimationClips);
    PApplet.println("TODO ColladaLibraryAnimationClips");
  }
}

public static class ColladaLibraryAnimations extends ColladaPart
{
  public ColladaLibraryAnimations(XML libraryAnimations) throws Exception
  {
    super(libraryAnimations);
    PApplet.println("TODO ColladaLibraryAnimations");
  }
}

public static class ColladaSampler extends ColladaPart
{
  public ColladaSampler(XML sampler) throws Exception
  {
    super(sampler);
    PApplet.println("TODO ColladaSampler");
  }
}

/* Camera */

public static class ColladaCamera extends ColladaPart
{
  public ColladaCamera(XML camera) throws Exception
  {
    super(camera);
    PApplet.println("TODO ColladaCamera");
  }
}

public static class ColladaImager extends ColladaPart
{
  public ColladaImager(XML imager) throws Exception
  {
    super(imager);
    PApplet.println("TODO ColladaImager");
  }
}

public static class ColladaInstanceCamera extends ColladaPart
{
  public ColladaInstanceCamera(XML instanceCamera) throws Exception
  {
    super(instanceCamera);
    PApplet.println("TODO ColladaInstanceCamera");
  }
}

public static class ColladaLibraryCameras extends ColladaPart
{
  public ColladaLibraryCameras(XML libraryCameras) throws Exception
  {
    super(libraryCameras);
    PApplet.println("TODO ColladaLibraryCameras");
  }
}

public static class ColladaOptics extends ColladaPart
{
  public ColladaOptics(XML optics) throws Exception
  {
    super(optics);
    PApplet.println("TODO ColladaOptics");
  }
}

public static class ColladaOrthographic extends ColladaPart
{
  public ColladaOrthographic(XML orthographic) throws Exception
  {
    super(orthographic);
    PApplet.println("TODO ColladaOrthographic");
  }
}

public static class ColladaPerspective extends ColladaPart
{
  public ColladaPerspective(XML perspective) throws Exception
  {
    super(perspective);
    PApplet.println("TODO ColladaPerspective");
  }
}
/* Controller */

public static class ColladaBindShapeMatrix extends ColladaPart
{
  protected float[][] content = new float[4][4];
  
  public ColladaBindShapeMatrix(XML bindShapeMatrix) throws Exception
  {
    super(bindShapeMatrix);
    
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
  
  public ColladaController(XML controller) throws Exception
  {
    super(controller);
    
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
  
  public ColladaInstanceController(XML instanceController) throws Exception
  {
    super(instanceController);
    
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
  public ColladaJoints(XML joints) throws Exception
  {
    super(joints);
    PApplet.println("TODO ColladaJoints");
  }
}

public static class ColladaLibraryControllers extends ColladaPart
{
  protected String id = null;
  protected String name = null;
  
  protected ColladaAsset asset = null;
  protected List<ColladaController> controllerList = new ArrayList<ColladaController>();
  protected List<ColladaExtra> extraList = new ArrayList<ColladaExtra>();
  
  public ColladaLibraryControllers(XML libraryControllers) throws Exception
  {
    super(libraryControllers);
    
    id = parseAttribute(libraryControllers, "id", String.class);
    name = parseAttribute(libraryControllers, "name", String.class);
    
    asset = parseChild(libraryControllers, "asset", ColladaAsset.class);
    parseChildren(libraryControllers, "controller", ColladaController.class, controllerList);
    parseChildren(libraryControllers, "extra", ColladaExtra.class, extraList);
  }
}

public static class ColladaMorph extends ColladaPart
{
  public ColladaMorph(XML morph) throws Exception
  {
    super(morph);
    PApplet.println("TODO ColladaMorph");
  }
}

public static class ColladaSkeleton extends ColladaPart
{
  public ColladaSkeleton(XML skeleton) throws Exception
  {
    super(skeleton);
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
  
  public ColladaSkin(XML skin) throws Exception
  {
    super(skin);
    
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
  public ColladaTargets(XML targets) throws Exception
  {
    super(targets);
    PApplet.println("TODO ColladaTargets");
  }
}

public static class ColladaVertexWeights extends ColladaPart
{
  public ColladaVertexWeights(XML vertexWeights) throws Exception
  {
    super(vertexWeights);
    PApplet.println("TODO ColladaVertexWeights");
  }
}

/* Data Flow */

public static class ColladaAccessor extends ColladaPart
{
  public ColladaAccessor(XML accessor) throws Exception
  {
    super(accessor);
    PApplet.println("TODO ColladaAccessor");
  }
}

public static class ColladaBoolArray extends ColladaPart
{
  public ColladaBoolArray(XML boolArray) throws Exception
  {
    super(boolArray);
    PApplet.println("TODO ColladaBoolArray");
  }
}

public static class ColladaFloatArray extends ColladaPart
{
  public ColladaFloatArray(XML floatArray) throws Exception
  {
    super(floatArray);
    PApplet.println("TODO ColladaFloatArray");
  }
}

public static class ColladaIDREFArray extends ColladaPart
{
  public ColladaIDREFArray(XML idrefArray) throws Exception
  {
    super(idrefArray);
    PApplet.println("TODO ColladaIDREFArray");
  }
}

public static class ColladaIntArray extends ColladaPart
{
  public ColladaIntArray(XML intArray) throws Exception
  {
    super(intArray);
    PApplet.println("TODO ColladaIntArray");
  }
}

public static class ColladaNameArray extends ColladaPart
{
  public ColladaNameArray(XML nameArray) throws Exception
  {
    super(nameArray);
    PApplet.println("TODO ColladaNameArray");
  }
}

public static class ColladaParam extends ColladaPart
{
  public ColladaParam(XML param) throws Exception
  {
    super(param);
    PApplet.println("TODO ColladaParam");
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
  protected ColladaTechniqueCommon techniqueCommon = null;
  protected List<ColladaTechnique> colladaTechniqueList = new ArrayList<ColladaTechnique>();
  
  public ColladaSource(XML source) throws Exception
  {
    super(source);
    
    id = parseAttribute(source, "id", String.class);
    name = parseAttribute(source, "name", String.class);
    
    asset = parseChild(source, "asset", ColladaAsset.class);
    idrefArray = parseChild(source, "IDREF_array", ColladaIDREFArray.class);
    nameArray = parseChild(source, "Name_array", ColladaNameArray.class);
    boolArray = parseChild(source, "bool_array", ColladaBoolArray.class);
    floatArray = parseChild(source, "float_array", ColladaFloatArray.class);
    intArray = parseChild(source, "int_array", ColladaIntArray.class);
    techniqueCommon = parseChild(source, "technique_common", ColladaTechniqueCommon.class);
    parseChildren(source, "technique", ColladaTechnique.class, colladaTechniqueList);
  }
}

public static class ColladaInput extends ColladaPart
{
  public ColladaInput(XML input) throws Exception
  {
    super(input);
    PApplet.println("TODO ColladaInput");
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
 
  public ColladaExtra(XML extra) throws Exception
  {
    super(extra);
    id = parseAttribute(extra, "id", String.class);
    name = parseAttribute(extra, "name", String.class);
    type = parseAttribute(extra, "type", String.class);
    
    asset = parseChild(extra, "asset", ColladaAsset.class);
    parseChildren(extra, "technique", ColladaTechnique.class, techniqueList);
  }
}

public static class ColladaTechnique extends ColladaPart
{
  protected String profile = null;
  protected String xmlns = null;  
  
  public ColladaTechnique(XML technique) throws Exception
  {
    super(technique);
    profile = parseAttribute(technique, "profile", String.class);
    xmlns = parseAttribute(technique, "xmlns", String.class);
  }
}

public static class ColladaTechniqueCommon extends ColladaPart
{
  public ColladaTechniqueCommon(XML techniqueCommon) throws Exception
  {
    super(techniqueCommon);
    PApplet.println("TODO ColladaTechniqueCommon");
  }
}

/* Geometry */

public static class ColladaControlVertices extends ColladaPart
{
  public ColladaControlVertices(XML controlVertices) throws Exception
  {
    super(controlVertices);
    PApplet.println("TODO ColladaControlVertices");
  }
}

public static class ColladaGeometry extends ColladaPart
{
  public ColladaGeometry(XML geometry) throws Exception
  {
    super(geometry);
    PApplet.println("TODO ColladaGeometry");
  }
}

public static class ColladaInstanceGeometry extends ColladaPart
{
  protected String sid = null;
  protected String name = null;
  protected String url = null;  
  
  //protected ColladaBindMaterial bindMaterial = null;
  protected List<ColladaExtra> extraList = new ArrayList<ColladaExtra>();
  
  public ColladaInstanceGeometry(XML instanceGeometry) throws Exception
  {
    super(instanceGeometry);
    
    sid = parseAttribute(instanceGeometry,"sid",String.class);
    name = parseAttribute(instanceGeometry,"name",String.class);
    url = parseAttribute(instanceGeometry,"url",String.class);
    
    //bindMaterial = parseChild(instanceGeometry, "bind_material", ColladaBindMaterial.class);
    parseChildren(instanceGeometry, "extra", ColladaExtra.class, extraList);
  }
}

public static class ColladaLibraryGeometries extends ColladaPart
{
  public ColladaLibraryGeometries(XML libraryGeometries) throws Exception
  {
    super(libraryGeometries);
    PApplet.println("TODO ColladaLibraryGeometries");
  }
}

public static class ColladaLines extends ColladaPart
{
  public ColladaLines(XML lines) throws Exception
  {
    super(lines);
    PApplet.println("TODO ColladaLines");
  }
}

public static class ColladaLineStrips extends ColladaPart
{
  public ColladaLineStrips(XML lineStrips) throws Exception
  {
    super(lineStrips);
    PApplet.println("TODO ColladaLineStrips");
  }
}

public static class ColladaMesh extends ColladaPart
{
  public ColladaMesh(XML mesh) throws Exception
  {
    super(mesh);
    PApplet.println("TODO ColladaMesh");
  }
}

public static class ColladaPolygons extends ColladaPart
{
  public ColladaPolygons(XML polygons) throws Exception
  {
    super(polygons);
    PApplet.println("TODO ColladaPolygons");
  }
}

public static class ColladaPolyList extends ColladaPart
{
  public ColladaPolyList(XML polyList) throws Exception
  {
    super(polyList);
    PApplet.println("TODO ColladaPolyList");
  }
}

public static class ColladaSpline extends ColladaPart
{
  public ColladaSpline(XML spline) throws Exception
  {
    super(spline);
    PApplet.println("TODO ColladaSpline");
  }
}

public static class ColladaTriangles extends ColladaPart
{
  public ColladaTriangles(XML triangles) throws Exception
  {
    super(triangles);
    PApplet.println("TODO ColladaTriangles");
  }
}

public static class ColladaTriFans extends ColladaPart
{
  public ColladaTriFans(XML triFans) throws Exception
  {
    super(triFans);
    PApplet.println("TODO ColladaTriFans");
  }
}

public static class ColladaTriStrips extends ColladaPart
{
  public ColladaTriStrips(XML triStrips) throws Exception
  {
    super(triStrips);
    PApplet.println("TODO ColladaTriStrips");
  }
}

public static class ColladaVertices extends ColladaPart
{
  public ColladaVertices(XML vertices) throws Exception
  {
    super(vertices);
    PApplet.println("TODO ColladaVertices");
  }
}

/* Lighting */

public static class ColladaAmbient extends ColladaPart
{
  public ColladaAmbient(XML ambient) throws Exception
  {
    super(ambient);
    PApplet.println("TODO ColladaAmbient");
  }
}

public static class ColladaColor extends ColladaPart
{
  public ColladaColor(XML kolor) throws Exception
  {
    super(kolor);
    PApplet.println("TODO ColladaColor");
  }
}

public static class ColladaDirectional extends ColladaPart
{
  public ColladaDirectional(XML directional) throws Exception
  {
    super(directional);
    PApplet.println("TODO ColladaDirectional");
  }
}

public static class ColladaInstanceLight extends ColladaPart
{
  public ColladaInstanceLight(XML instanceLight) throws Exception
  {
    super(instanceLight);
    PApplet.println("TODO ColladaInstanceLight");
  }
}

public static class ColladaLibraryLights extends ColladaPart
{
  public ColladaLibraryLights(XML libraryLights) throws Exception
  {
    super(libraryLights);
    PApplet.println("TODO ColladaLibraryLights");
  }
}

public static class ColladaLight extends ColladaPart
{
  public ColladaLight(XML light) throws Exception
  {
    super(light);
    PApplet.println("TODO ColladaLight");
  }
}

public static class ColladaPoint extends ColladaPart
{
  public ColladaPoint(XML point) throws Exception
  {
    super(point);
    PApplet.println("TODO ColladaPoint");
  }
}

public static class ColladaSpot extends ColladaPart
{
  public ColladaSpot(XML spot) throws Exception
  {
    super(spot);
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
  
  public ColladaAsset(XML asset) throws Exception
  {
    super(asset);
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
  
  public ColladaAuthor(XML author) throws Exception
  {
    super(author);
    content = author.getContent();
  }
}

public static class ColladaAuthoringTool extends ColladaPart
{
  protected String content = null;
  
  public ColladaAuthoringTool(XML authoringTool) throws Exception
  {
    super(authoringTool);
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
  
  public Collada(XML collada) throws Exception
  {
    super(collada);
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
}

public static class ColladaComments extends ColladaPart
{
  protected String content = null;
  
  public ColladaComments(XML comments) throws Exception
  {
    super(comments);
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
  
  public ColladaContributor(XML contributor) throws Exception
  {
    super(contributor);
    author = parseChild(contributor, "author", ColladaAuthor.class);
    authoringTool = parseChild(contributor, "authoring_tool", ColladaAuthoringTool.class);
    comments = parseChild(contributor, "comments", ColladaComments.class);
    copyright = parseChild(contributor, "copyright", ColladaCopyright.class);
    sourceData = parseChild(contributor, "source_data", ColladaSourceData.class);
  }
}

public static class ColladaCopyright extends ColladaPart
{
  public ColladaCopyright(XML copyright) throws Exception
  {
    super(copyright);
    PApplet.println("TODO ColladaCopyright");
  }
}

public static class ColladaCreated extends ColladaPart
{
  protected String content = null;
  
  public ColladaCreated(XML created) throws Exception
  {
    super(created);
    content = created.getContent();
  }
}

public static class ColladaKeywords extends ColladaPart
{
  protected String content = null;
  
  public ColladaKeywords(XML keywords) throws Exception
  {
    super(keywords);
    content = keywords.getContent();
  }
}

public static class ColladaModified extends ColladaPart
{
  protected String content = null;
  
  public ColladaModified(XML modified) throws Exception
  {
    super(modified);
    content = modified.getContent();
  }
}

public static class ColladaRevision extends ColladaPart
{
  protected String content = null;
  
  public ColladaRevision(XML revision) throws Exception
  {
    super(revision);
    content = revision.getContent();
  }
}

public static class ColladaSourceData extends ColladaPart
{
  public ColladaSourceData(XML sourceData) throws Exception
  {
    super(sourceData);
    PApplet.println("TODO ColladaSourceData");
  }
}

public static class ColladaSubject extends ColladaPart
{
  protected String content = null;
  
  public ColladaSubject(XML subject) throws Exception
  {
    super(subject);
    content = subject.getContent();
  }
}

public static class ColladaTitle extends ColladaPart
{
  protected String content = null;
  
  public ColladaTitle(XML title) throws Exception
  {
    super(title);
    content = title.getContent();
  }
}

public static class ColladaUnit extends ColladaPart
{
  protected String name = null;
  protected Float meter = null;
  
  public ColladaUnit(XML unit) throws Exception
  {
    super(unit);
    name = parseAttribute(unit, "name", String.class, "meter");
    meter = parseAttribute(unit, "meter", Float.class, 1.0);
  }
}

public static class ColladaUpAxis extends ColladaPart
{
  protected String content = "Y_UP";
  
  public ColladaUpAxis(XML upAxis) throws Exception
  {
    super(upAxis);
    content = upAxis.getContent();
  }
}

/* Scene */

public static class ColladaEvaluateScene extends ColladaPart
{
  protected String name = null;
  //protected List<ColladaRender> renderList = new ArrayList<ColladaRender>();
  
  public ColladaEvaluateScene(XML evaluateScene) throws Exception
  {
    super(evaluateScene);
    
    name = parseAttribute(evaluateScene, "name", String.class);
  }
}

public static class ColladaInstanceNode extends ColladaPart
{
  public ColladaInstanceNode(XML instanceNode) throws Exception
  {
    super(instanceNode);
    PApplet.println("TODO ColladaInstanceNode");
  }
}

public static class ColladaInstanceVisualScene extends ColladaPart
{
  protected String sid = null;
  protected String name = null;
  protected String url = null;
  
  public ColladaInstanceVisualScene(XML instanceVisualScene) throws Exception
  {
    super(instanceVisualScene);
    sid = parseAttribute(instanceVisualScene, "sid", String.class);
    name = parseAttribute(instanceVisualScene, "name", String.class);
    url = parseAttribute(instanceVisualScene, "url", String.class);
  }
}

public static class ColladaLibraryNodes extends ColladaPart
{
  public ColladaLibraryNodes(XML libraryNodes) throws Exception
  {
    super(libraryNodes);
    PApplet.println("TODO ColladaLibraryNodes");
  }
}

public static class ColladaLibraryVisualScenes extends ColladaPart
{
  protected String id = null;
  protected String name = null;
  
  protected ColladaAsset asset = null;
  protected List<ColladaVisualScene> visualSceneList = new ArrayList<ColladaVisualScene>();
  protected List<ColladaExtra> extraList = new ArrayList<ColladaExtra>();
  
  public ColladaLibraryVisualScenes(XML libraryVisualScenes) throws Exception
  {
    super(libraryVisualScenes);
    
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
  
  public ColladaNode(XML node) throws Exception
  {
    super(node);
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
}

public static class ColladaScene extends ColladaPart
{
  //protected List<ColladaInstancePhysicsScene> instancePhysicsSceneList = new ArrayList<ColladaInstancePhysicsScene>();
  protected ColladaInstanceVisualScene instanceVisualScene = null;
  protected List<ColladaExtra> extraList = new ArrayList<ColladaExtra>();
  
  public ColladaScene(XML scene) throws Exception
  {
    super(scene);
    //parseChildren(scene, "instance_physics_scene",ColladaInstancePhysicsScene.class,instancePhysicsSceneList);
    instanceVisualScene = parseChild(scene, "instance_visual_scene", ColladaInstanceVisualScene.class);
    parseChildren(scene, "extra",ColladaExtra.class,extraList);    
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
  
  public ColladaVisualScene(XML visualScene) throws Exception
  {
    super(visualScene);
    id = parseAttribute(visualScene, "id", String.class);
    name = parseAttribute(visualScene, "name", String.class);
    
    asset = parseChild(visualScene, "asset", ColladaAsset.class);
    parseChildren(visualScene, "node", ColladaNode.class, nodeList);
    parseChildren(visualScene, "evaluate_scene", ColladaEvaluateScene.class, evaluateSceneList);
    parseChildren(visualScene, "extra", ColladaExtra.class, extraList);
  }
}

/* Transform */

public static class ColladaLookAt extends ColladaPart
{
  public ColladaLookAt(XML lookAt) throws Exception
  {
    super(lookAt);
    PApplet.println("TODO ColladaLookAt");
  }
}

public static class ColladaMatrix extends ColladaPart
{
  protected String sid = null;
  protected float[][] content = new float[4][4];
  
  public ColladaMatrix(XML matrix) throws Exception
  {
    super(matrix);
    
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
  public ColladaRotate(XML rotate) throws Exception
  {
    super(rotate);
    PApplet.println("TODO ColladaRotate");
  }
}

public static class ColladaScale extends ColladaPart
{
  public ColladaScale(XML scale) throws Exception
  {
    super(scale);
    PApplet.println("TODO ColladaScale");
  }
}

public static class ColladaSkew extends ColladaPart
{
  public ColladaSkew(XML skew) throws Exception
  {
    super(skew);
    PApplet.println("TODO ColladaSkew");
  }
}

public static class ColladaTranslate extends ColladaPart
{
  public ColladaTranslate(XML translate) throws Exception
  {
    super(translate);
    PApplet.println("TODO ColladaTranslate");
  }
}
/*

public static class Collada extends ColladaPart
{
  protected List<ColladaLibraryGeometries> libraryGeometriesList = new ArrayList<ColladaLibraryGeometries>();
  
  public Collada(XML collada)
  {
    super(collada);
    for(XML libraryGeometries : collada.getChildren("library_geometries"))
    {
      libraryGeometriesList.add(new ColladaLibraryGeometries(libraryGeometries));
    }
  }
}

public static class ColladaLibraryGeometries extends ColladaPart
{
  protected List<ColladaGeometry> geometryList = new ArrayList<ColladaGeometry>();
  
  public ColladaLibraryGeometries(XML libraryGeometries)
  {
    super(libraryGeometries);
    for(XML geometry : libraryGeometries.getChildren("geometry"))
    {
      geometryList.add(new ColladaGeometry(geometry));
    }    
  }
}

public static class ColladaGeometry extends ColladaPart
{
  protected ColladaMesh mesh = null;
  
  public ColladaGeometry(XML geometry)
  {
    super(geometry);
    XML child = null;
    if((child = geometry.getChild("mesh")) != null)
    {
      mesh = new ColladaMesh(child);
    }
  }
}

public static class ColladaMesh extends ColladaPart
{
  protected List<ColladaSource> sourcesList = new ArrayList<ColladaSource>();
  protected ColladaVertices vertices = null;
  
  public ColladaMesh(XML mesh)
  {
    super(mesh);
    XML child = null;
    
    for(XML source : mesh.getChildren("source"))
    {
      sourcesList.add(new ColladaSource(source));
    }

    if((child = mesh.getChild("vertices")) != null)
    {
      vertices = new ColladaVertices(child);
    }    
  }
}

public static class ColladaVertices extends ColladaPart
{
  protected List<ColladaInput> inputsList = new ArrayList<ColladaInput>(); 
  
  public ColladaVertices(XML vertices)
  {
    super(vertices);

    for(XML input : vertices.getChildren("input"))
    {
      inputsList.add(new ColladaInput(input));
    }    
  }
}

public static class ColladaInput extends ColladaPart
{
  protected Integer offset = null;
  protected String semantic = null;
  protected String source = null;
  protected Integer set = null;
  
  public ColladaInput(XML input)
  {
    super(input);
    String attribute = null;

    if((attribute = input.getString("offset")) != null)
    {
      offset = Integer.valueOf(attribute);
    }
    if((attribute = input.getString("semantic")) != null)
    {
      semantic = attribute;
    }    
    if((attribute = input.getString("source")) != null)
    {
      source = attribute;
    }    
    if((attribute = input.getString("set")) != null)
    {
      set = Integer.valueOf(attribute);
    }        
  }
}

public static class ColladaSource extends ColladaPart
{
  protected ColladaIDREFArray idrefArray = null;
  protected ColladaNameArray nameArray = null;
  protected ColladaBoolArray boolArray = null;
  protected ColladaFloatArray floatArray = null;
  protected ColladaIntArray intArray = null;
  
  public ColladaSource(XML source)
  {
    super(source);
    XML child = null;
    if((child = source.getChild("IDREF_array")) != null)
    {
      idrefArray = new ColladaIDREFArray(child);
    }
    if((child = source.getChild("Name_array")) != null)
    {
      nameArray = new ColladaNameArray(child);
    }
    if((child = source.getChild("bool_array")) != null)
    {
      boolArray = new ColladaBoolArray(child);
    }
    if((child = source.getChild("float_array")) != null)
    {
      floatArray = new ColladaFloatArray(child);
    }
    if((child = source.getChild("int_array")) != null)
    {
      intArray = new ColladaIntArray(child);
    }    
  }
}

public static class ColladaIDREFArray extends ColladaPart
{
  protected List<String> idrefsList = new ArrayList<String>();
  
  public ColladaIDREFArray(XML idrefArray)
  {
    super(idrefArray);
    for(String value : idrefArray.getContent().split("\\s+"))
    {
      if(value.length() > 0)
      {
        idrefsList.add(value);
      }
    }        
  }
}

public static class ColladaNameArray extends ColladaPart
{
  protected List<String> namesList = new ArrayList<String>();  
  
  public ColladaNameArray(XML nameArray)
  {
    super(nameArray);
    for(String value : nameArray.getContent().split("\\s+"))
    {
      if(value.length() > 0)
      {
        namesList.add(value);
      }
    }    
  }
}

public static class ColladaBoolArray extends ColladaPart
{
  protected List<Boolean> booleansList = new ArrayList<Boolean>();  
  
  public ColladaBoolArray(XML boolArray)
  {
    super(boolArray);
    for(String value : boolArray.getContent().split("\\s+"))
    {
      if(value.length() > 0)
      {      
        booleansList.add(Boolean.valueOf(value));
      }
    }    
  }
}

public static class ColladaFloatArray extends ColladaPart
{
  protected List<Float> floatsList = new ArrayList<Float>();  
  
  public ColladaFloatArray(XML floatArray)
  {
    super(floatArray);
    for(String value : floatArray.getContent().split("\\s+"))
    {
      if(value.length() > 0)
      {
        floatsList.add(Float.valueOf(value));
      }
    }
  }
}

public static class ColladaIntArray extends ColladaPart
{
  protected List<Integer> integersList = new ArrayList<Integer>();  
  
  public ColladaIntArray(XML intArray)
  {
    super(intArray);
    for(String value : intArray.getContent().split("\\s+"))
    {
      if(value.length() > 0)
      {      
        integersList.add(Integer.valueOf(value));
      }
    }    
  }
}

*/
