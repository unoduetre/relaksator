public static abstract class View extends Widget
{
  protected PVector previousMousePosition = null;
  protected Collada collada = null;
  
  public View(PApplet pApplet, Collada collada)
  {
    super(pApplet);
    this.collada = collada;
  }

  public abstract void show();
  
  public abstract void hide();
  
  public void mousePressed(PVector mousePosition) throws Exception
  {
    previousMousePosition = mousePosition;
  }
  
  public void mouseReleased(PVector mousePosition) throws Exception
  {
    previousMousePosition = mousePosition;    
  }

  public void mouseDragged(PVector mousePosition) throws Exception
  {
    previousMousePosition = mousePosition;    
  }
  
  public void onTap(PVector position) throws Exception
  {
  }
  
  public void onFlick(PVector end, PVector start, Float speed) throws Exception
  {
  }
  
  public void onPinch(PVector position, Float distance) throws Exception
  {
  }

  public void onRotate(PVector position, Float angle) throws Exception
  {
  }  
}

