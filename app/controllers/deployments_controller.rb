class DeploymentsController < ApplicationController
  def index
    @docker_available = system("docker", "info", out: File::NULL, err: File::NULL)
  end
end
