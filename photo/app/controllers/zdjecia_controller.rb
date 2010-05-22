class ZdjeciaController < ApplicationController
before_filter :require_user, :except => [:show, :index]

  def index
    # wyszukiwanie: wedlug tagow, potem wedlug opisow, jezeli szukana fraza nie jest pusta
    if params[:search]
      @zdjecia = Zdjecie.tagged_with(params[:search], :on => :tags).paginate :page => params[:page], :per_page => 8
      tag_cloud
    elsif params[:szukaj_opisu]
      if params[:szukaj_opisu].length == 0
        flash[:notice] = "Nie znaleziono żadnego zdjęcia, należy wpisać jakiś tekst do wyszukiwarki!"
        redirect_to root_path       
      end
      @zdjecia = Zdjecie.find(:all, :conditions => [ "opis LIKE ?","%" + params[:szukaj_opisu] +"%"]).paginate :page => params[:page], :per_page => 8
      tag_cloud
    else
      @zdjecia = Zdjecie.all.paginate :page => params[:page], :per_page => 8
      tag_cloud
    end
  end
  
  def tag
    @zdjecia = Zdjecie.tagged_with(params[:id], :on => :tags)
    tag_cloud
  end

  def tag_cloud
    @tags = Zdjecie.tag_counts_on(:tags)
  end  

  def rate
    @zdjecie = Zdjecie.find(params[:id])
    @zdjecie.rate(params[:stars], current_user, params[:dimension])
    render :update do |page|
      page.replace_html @zdjecie.wrapper_dom_id(params), ratings_for(@zdjecie, params.merge(:wrap => false))
      page.visual_effect :highlight, @zdjecie.wrapper_dom_id(params)
    end
  end

  def show
    @zdjecie = Zdjecie.find(params[:id])
    @komentarze = @zdjecie.komentarze.all
    Zdjecie.transaction do
      z = Zdjecie.find(params[:id])
      z.update_attribute( :licznik, z.licznik + 1 )
    end
  end
  
  def new
    @zdjecie = Zdjecie.new
  end
  
  def create
    @zdjecie = Zdjecie.new(params[:zdjecie])
    if @zdjecie.save
      flash[:notice] = "Pomyślnie dodano zdjęcie!"
      if params[:zdjecie][:photo].blank?
        redirect_to @zdjecie
      else
        render :action => 'crop'
      end
   else
      render :action => 'new'
    end
  end

  def edit
    @zdjecie = Zdjecie.find(params[:id])
  end
  
  def update
    @zdjecie = Zdjecie.find(params[:id])
    if @zdjecie.update_attributes(params[:zdjecie])
      flash[:notice] = "Pomyślnie zmieniono zdjęcie."
      if params[:zdjecie][:photo].blank?
        redirect_to @zdjecie
      else
        render :action => 'crop'
      end
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @zdjecie = Zdjecie.find(params[:id])
    @zdjecie.destroy
    flash[:notice] = "Zdjęcie zostało zniszczone."
    redirect_to zdjecia_url
  end
  
end
