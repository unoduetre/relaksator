import ketai.camera.KetaiCamera;

public static class MatchingView extends View
{
  
  protected KetaiCamera camera = null;
  protected PImage photo = null;
  protected Integer previewWidth = null;
  protected Integer previewHeight = null;
  
  
  protected Boolean takingPhoto = true;
  
  public MatchingView(PApplet pApplet, Collada collada)
  {
    super(pApplet, collada);
    
    camera = new KetaiCamera(pApplet, 640, 480, 30);
    
    Float ratio = null;
    
    if(pApplet.width/pApplet.height > 640/480)
    {
      ratio = pApplet.height / 480.0;
    }
    else
    {
      ratio = pApplet.width / 640.0;
    }
    previewWidth = int(ratio * 640.0);
    previewHeight = int(ratio * 480.0);
  }
  
  public void show()
  {
    takingPhoto = true;
    camera.start();
  }
  
  public void hide()
  {
    camera.stop();    
  }
  
  public void draw() throws Exception
  {
    pApplet.background(0,0,0);          
    if(takingPhoto)
    {
      camera.read();
      pApplet.image(camera,(pApplet.width - previewWidth) / 2,(pApplet.height - previewHeight) / 2, previewWidth, previewHeight);
    }
    else
    {
      pApplet.image(photo,(pApplet.width - previewWidth) / 2,(pApplet.height - previewHeight) / 2, previewWidth, previewHeight);
    }
  }  
  
  public void mousePressed(PVector mousePosition) throws Exception
  {
    if(takingPhoto)
    {
      photo = camera.get();
      camera.stop();    
      takingPhoto = false; 
    }
    else
    {
    }
    super.mousePressed(mousePosition);    
  }
  
  public void mouseReleased(PVector mousePosition) throws Exception
  {
    super.mouseReleased(mousePosition);
  }
  
  public void mouseDragged(PVector mousePosition) throws Exception
  {
    super.mouseDragged(mousePosition);
  }  
}
