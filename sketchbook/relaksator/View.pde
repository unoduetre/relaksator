public static abstract class View extends Widget
{
  protected PVector previousMousePosition;
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
}

