Rails.application.routes.draw do
  root 'infos#about'
  get  'api/client/fetch/combined' => 'api/client/clients#fetch_combined'
  get  'api/client/fetch/appended' => 'api/client/clients#fetch_appended'
end
