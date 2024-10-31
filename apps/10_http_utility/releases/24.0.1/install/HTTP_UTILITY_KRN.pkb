SET DEFINE OFF

CREATE OR REPLACE PACKAGE BODY http_utility_krn IS
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
   * Log a message.
   *
   * @param p_message: message to be displayed
   */
   PROCEDURE log_msg(p_message IN VARCHAR2) IS
   BEGIN

      -- Check whether the package is in verbose mode.
      IF http_utility_var.g_verbose THEN

         -- Display the message.
         SYS.DBMS_OUTPUT.PUT_LINE(
            TO_CHAR(SYSTIMESTAMP, http_utility_var.gk_timestamp_format)
         || ' - '
         || NVL(TRIM(p_message), ' ')
         );

      END IF;

   EXCEPTION
      WHEN OTHERS THEN
         NULL;

   END log_msg;

   /**
   * Initialize the verbose mode.
   *
   * @param p_verbose: whether the verbose mode must be activated
   */
   PROCEDURE set_verbose(p_verbose BOOLEAN) IS
   BEGIN
      http_utility_var.g_verbose := NVL(p_verbose, FALSE);
   END set_verbose;

   /**
   * Raise an application error.
   *
   * @param p_code: error code
   * @param p_msg: error message
   */
   PROCEDURE raise_error(
      p_code            IN  SIMPLE_INTEGER
    , p_msg             IN  VARCHAR2
   ) IS
   BEGIN
      IF p_msg IS NOT NULL THEN
         log_msg('ERROR:');
         log_msg(p_msg);
      END IF;
      RAISE_APPLICATION_ERROR(p_code, NVL(p_msg, '/'));
   END raise_error;

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
    , p_wallet_path     IN  VARCHAR2   DEFAULT NULL
    , p_proxy           IN  VARCHAR2   DEFAULT NULL
    , p_verbose         IN  BOOLEAN    DEFAULT FALSE
   ) IS

      -- URL
      url               VARCHAR2(4000);

      -- HTTP request
      http_request      UTL_HTTP.REQ;

      -- HTTP response
      http_response     UTL_HTTP.RESP;

      -- HTTP response code
      http_resp_code    INTEGER;

      -- HTTP response reason
      http_resp_reason  VARCHAR2(32767);

      -- HTTP response text
      http_resp_text    VARCHAR2(32767);

      /**
      * Close the HTTP response.
      */
      PROCEDURE close_http_response IS
      BEGIN
         UTL_HTTP.END_RESPONSE(http_response);
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END close_http_response;

   BEGIN

      -- Initialize the verbose mode.
      set_verbose(p_verbose);

      -- Check the URL.
      url := TRIM(p_url);
      IF url IS NULL THEN
         raise_error(http_utility_var.gk_errcode_inv_prm, 'invalid URL');
      END IF;
      log_msg('URL: ' || url);

      -- Initialize the proxy server address if needed.
      IF TRIM(p_proxy) IS NOT NULL THEN
         UTL_HTTP.SET_PROXY(TRIM(p_proxy));
         log_msg('Proxy server address initialized: ' || TRIM(p_proxy));
      ELSE
         log_msg('No proxy server.');
      END IF;

      -- Initialize the wallet path.
      IF TRIM(p_wallet_path) IS NOT NULL THEN
         UTL_HTTP.SET_WALLET(TRIM(p_wallet_path));
         log_msg('Wallet path initialized: ' || TRIM(p_wallet_path));
      ELSE
         log_msg('No wallet path');
      END IF;

      -- Initialize the HTTP request.
      http_request := UTL_HTTP.BEGIN_REQUEST(
         url
       , 'POST'
       , http_utility_var.gk_http_version
      );
      UTL_HTTP.SET_HEADER(http_request, 'Content-Type', 'application/json');
      UTL_HTTP.SET_HEADER(http_request, 'User-Agent', 'PL/SQL');
      log_msg('HTTP request initialized/');

      -- Send the request.
      http_response := UTL_HTTP.GET_RESPONSE(http_request);
      http_resp_code := http_response.STATUS_CODE;
      http_resp_reason := http_response.REASON_PHRASE;
      log_msg('HTTP request sent.');
      log_msg('HTTP response code: ' || NVL(TO_CHAR(http_resp_code), '/'));
      log_msg('HTTP response reason: ' || NVL(http_resp_reason, '/'));

      -- Check the status code.
      IF http_resp_code BETWEEN 400 AND 599 THEN
         raise_error(
            http_utility_var.gk_errcode_http_req_fail
          , 'Sending HTTP request failure: '
         || NVL(TO_CHAR(http_resp_code), ' / ')
         || ' - '
         || NVL(http_resp_reason, ' / ')
         );
      END IF;

      -- Display the response text.
      IF http_utility_var.g_verbose THEN
         BEGIN
            log_msg('HTTP request response text:');
            <<browse_resp_text>>
            LOOP
               UTL_HTTP.READ_TEXT(http_response, http_resp_text);
               log_msg(http_resp_text);
            END LOOP browse_resp_text;
         EXCEPTION
            WHEN UTL_HTTP.END_OF_BODY THEN
               NULL;
         END;
      END IF;

      -- Close the HTTP response.
      close_http_response;

   EXCEPTION
      WHEN OTHERS THEN
         close_http_response();
         RAISE;

   END send_http_request;

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
   ) IS

      -- URL
      url               VARCHAR2(4000);

   BEGIN

      -- Build the URL.
      url := TRIM(p_url_root);
      IF url IS NULL THEN
         raise_error(http_utility_var.gk_errcode_inv_prm, 'invalid URL');
      END IF;
      IF TRIM(p_token) IS NULL THEN
         raise_error(
            http_utility_var.gk_errcode_inv_prm
          , 'invalid GitLab token'
         );
      END IF;
      url := url || '?token=' || TRIM(p_token);
      IF TRIM(p_var_name) IS NOT NULL THEN
         IF TRIM(p_var_value) IS NULL THEN
            raise_error(
               http_utility_var.gk_errcode_inv_prm
             , 'Invalid variable value.'
            );
         END IF;
         url := url 
            || '&variables['
            || TRIM(p_var_name)
            || ']='
            || TRIM(p_var_value);
      END IF;

      -- Send the HTTP request.
      send_http_request(
         url
       , p_wallet_path
       , p_proxy
       , p_verbose
      );

   END send_gitlab_http_request;

END http_utility_krn;
/
