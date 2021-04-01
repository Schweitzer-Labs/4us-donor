module Config.Env exposing (env)

import Config exposing (Config)


env : Config
env =
    { apiEndpoint = "http://localhost:5000" }
