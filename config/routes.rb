Rails.application.routes.draw do
  root 'welcome#index'
  get '/coord' => 'welcome#redirect' 
  
  #NOTE: This routing must be at last. Many routings will conflict with this.
  get '/:p/:c' => 'welcome#index'
end
