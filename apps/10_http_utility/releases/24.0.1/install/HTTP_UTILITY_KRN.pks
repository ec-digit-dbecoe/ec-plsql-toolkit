CREATE OR REPLACE PACKAGE http_utility_krn
AUTHID DEFINER
IS
---
-- Copyright (C) 2023 European Commission
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the European Union Public License ash published by
-- the European Union, either version 1.1 of the License, or (at your option)
-- any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- European Union Public License for more details.
--
-- You should have received a copy of the European Union Public License
-- along with this program.  If not, see <https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
--

/**
* Implementation of HTTP related services.
*
* v1.00; 2024-09-26; malmjea; initial version
*/

   /**
   * Initialize the verbose mode.
   *
   * @param p_verbose: whether the verbose mode must be activated
   */
   PROCEDURE set_verbose(p_verbose BOOLEAN);

   /**
   * Send an HTTP request.
   *
   * @param p_url: HTTP request URL
   * @param p_wallet_path: path of the wallet storing the certificate
   * @param p_proxy: proxy server address
   * @param p_verbose: whether verbose mode must be activated
   * @throws http_utility_var.gk_errcode_inv_prm: invalid parameter
   * @throws http_utility_var.gk_errcode_http_req_fail: sending request
   * failure
   */
   PROCEDURE send_http_request (
      p_url             IN  VARCHAR2
    , p_wallet_path     IN  VARCHAR2 DEFAULT NULL
    , p_proxy           IN  VARCHAR2 DEFAULT NULL
    , p_verbose         IN  BOOLEAN DEFAULT FALSE
   );

   /**
   * Send a GitLab HTTP request.
   *
   * @param p_url_root: HTTP request URL root
   * @param p_token: token
   * @param p_var_name: variable name
   * @param p_var_value: variable value
   * @param p_wallet_path: path of the wallet storing the certificate
   * @param p_proxy: proxy server address
   * @param p_verbose: whether verbose mode must be activated
   * @throws http_utility_var.gk_errcode_inv_prm: invalid parameter
   * @throws http_utility_var.gk_errcode_http_req_fail: sending request
   * failure
   */
   PROCEDURE send_gitlab_http_request(
      p_url_root        IN  VARCHAR2
    , p_token           IN  VARCHAR2
    , p_var_name        IN  VARCHAR2   DEFAULT NULL
    , p_var_value       IN  VARCHAR2   DEFAULT NULL
    , p_wallet_path     IN  VARCHAR2   DEFAULT NULL
    , p_proxy           IN  VARCHAR2   DEFAULT NULL
    , p_verbose         IN  BOOLEAN    DEFAULT FALSE
   );
   
END http_utility_krn;
/
