Campuswise::Application.routes.draw do
  match "home"     => "static#home"

  root :to => "static#home"
end
