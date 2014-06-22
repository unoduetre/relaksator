import ketai.camera.KetaiCamera;
import papaya.Mat;
import java.util.LinkedList;

public static class Gesture 
{
  public static Gesture ROTATE = new Gesture();
  public static Gesture PINCH = new Gesture();
}

public static class MatchingView extends View
{

  protected Integer cameraWidth = 640;
  protected Integer cameraHeight = 480;  
  protected KetaiCamera camera = null;
  protected PImage photo = null;
  protected Integer previewWidth = null;
  protected Integer previewHeight = null;
  protected PImage uvImage = null;
  protected float[][] matrix = null;
  protected Float left = null;
  protected Float right = null;
  protected Float top = null;
  protected Float bottom = null;
  protected Gesture currentEvent = null;
  protected ColladaTriangles triangles = null;
  protected List<Float> uv = null;
  protected PGraphics graphics = null;
  
  protected ColladaFloatArray floatArray = null; 
  
  protected Boolean takingPhoto = true;
  
  public MatchingView(PApplet pApplet, Collada collada) throws Exception
  {
    super(pApplet, collada);
    
    camera = new KetaiCamera(pApplet, cameraWidth, cameraHeight, 30);
    graphics = pApplet.createGraphics(cameraHeight, cameraWidth);
    
    Float ratio = null;
    
    if(pApplet.height/pApplet.width > cameraWidth/cameraHeight)
    {
      ratio = float(pApplet.height) / float(cameraWidth);
    }
    else
    {
      ratio = float(pApplet.width) / float(cameraHeight);
    }
    previewWidth = int(ratio * cameraHeight);
    previewHeight = int(ratio * cameraWidth);
    
    left = (pApplet.width - previewWidth) / 2.0;
    top = (pApplet.height - previewHeight) / 2.0;
    right = left + previewWidth;
    bottom = top + previewHeight;
    
    uvImage = pApplet.loadImage("uv.png");
    triangles = ((ColladaGeometry)collada.getById("glowka001-lib")).getMesh().getTriangles();
    floatArray = ((ColladaTechniqueCommonInSource)triangles.getTexcoordSource().getTechnique()).getAccessor().getSource(ColladaFloatArray.class);
    floatArray.reset();
    uv = new ArrayList<Float>(floatArray.getContent());
  }
  
  public void show()
  {
    takingPhoto = true;
    camera.start();
    matrix = new float[][] {
      {1.0, 0.0, 0.0},
      {0.0, 1.0, 0.0},
      {0.0, 0.0, 1.0}
    };    
  }
  
  public void hide()
  {
    if(takingPhoto)
    {
      camera.stop();
    }
    
    for(Integer i = 0; i < uv.size(); i += 2)
    {
      float[] point = new float[] {uv.get(i), uv.get(i+1), 1.0};
      point = Mat.multiply(matrix, point);
      uv.set(i, point[0]);
      uv.set(i+1, point[1]);
    }
    floatArray.setContent(uv);
    triangles.setImage(photo);
  }
  
  public void draw() throws Exception
  {
    
    pApplet.background(0,0,0);          
    if(takingPhoto)
    {
      camera.read();
      graphics.beginDraw();
      graphics.translate(0, cameraWidth);
      graphics.rotate(-pApplet.HALF_PI);    
      graphics.image(camera, 0, 0);
      graphics.endDraw();
      pApplet.image(graphics, left, top, right, bottom);
    }
    else
    {
      pApplet.pushMatrix();
      
      pApplet.applyMatrix(
        right-left, 0.0, 0.0, left,
        0.0, top-bottom, 0.0, bottom,
        0.0, 0.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 1.0    
      );
      
      pApplet.pushMatrix();
      pApplet.applyMatrix(
        1.0, 0.0, 0.0, 0.0,
        0.0, -1.0, 0.0, 1.0,
        0.0, 0.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 1.0
      );
      pApplet.image(photo, 0, 0, 1, 1);
      pApplet.popMatrix();
      
      pApplet.applyMatrix(
        matrix[0][0],    matrix[0][1],    0.0,             matrix[0][2],
        matrix[1][0],    matrix[1][1],    0.0,             matrix[1][2],
        0.0,             0.0,             1.0,             0.0,
        matrix[2][0],    matrix[2][1],    0.0,             matrix[2][2]
      );     
      
      for(Integer i = 0; i < uv.size(); i += 2)
      {
        pApplet.ellipse(uv.get(i), uv.get(i+1),0.01,0.01);
      }
      
      
      pApplet.pushMatrix();
      pApplet.applyMatrix(
        1.0, 0.0, 0.0, 0.0,
        0.0, -1.0, 0.0, 1.0,
        0.0, 0.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 1.0
      );
      pApplet.image(uvImage, 0, 0, 1, 1);
      pApplet.popMatrix();      
      
      
      pApplet.popMatrix();      
    }
  }  
  
  public void mousePressed(PVector mousePosition) throws Exception
  {
    //pApplet.println("MOUSE PRESSED");    
    if(takingPhoto)
    {
      graphics.beginDraw();
      graphics.translate(0, cameraWidth);
      graphics.rotate(-pApplet.HALF_PI);    
      graphics.image(camera.get(), 0, 0);
      graphics.endDraw();      
      photo = graphics.get();
      camera.stop();    
      takingPhoto = false; 
    }
    super.mousePressed(mousePosition);
    currentEvent = null;   
  }
  
  public void mouseReleased(PVector mousePosition) throws Exception
  {
    //pApplet.println("MOUSE RELEASED");   
    super.mouseReleased(mousePosition);
  }
  
  public void mouseDragged(PVector mousePosition) throws Exception
  {
    if(currentEvent == Gesture.ROTATE)
    {
      return;
    }
    else if(currentEvent == Gesture.PINCH)
    {
      //pApplet.println("PINCH");
      PVector delta = PVector.sub(mousePosition, previousMousePosition);
      matrix[0][0] *= (pApplet.width + delta.x) / pApplet.width;
      matrix[1][1] *= (pApplet.height - delta.y) / pApplet.height;
    }
    else
    {
      //pApplet.println("MOUSE DRAGGED");
      PVector delta = PVector.sub(mousePosition,previousMousePosition);
      //pApplet.println("drag: "+String.valueOf(delta));
      matrix[0][2] += delta.x / (right - left);
      matrix[1][2] -= delta.y / (bottom - top);
    }    
    super.mouseDragged(mousePosition);
  }
  
  public void onFlick(PVector position, PVector delta, Float speed)
  {
    super.onFlick(position, delta, speed);    
  }
  
  public void onPinch(PVector position, Float distance)
  {
    super.onPinch(position, distance);  
    if(currentEvent != null)
    {
      return;
    }
    currentEvent = Gesture.PINCH;
  }

  public void onRotate(PVector position, Float angle)
  {
    super.onPinch(position, angle);
    if(pApplet.abs(angle) < 0.0001)
    {
      return;
    }
    //pApplet.println("ROTATE: "+String.valueOf(angle));
    currentEvent = Gesture.ROTATE;
    Float c = pApplet.cos(-angle);
    Float s = pApplet.sin(-angle);
    float[][] rotation = new float[][] {
      {c, -s, -0.5*c + 0.5*s + 0.5},
      {s,  c, -0.5*s - 0.5*c + 0.5},
      {0.0, 0.0, 1.0}
    };
    matrix = Mat.multiply(matrix, rotation);
  }
}
