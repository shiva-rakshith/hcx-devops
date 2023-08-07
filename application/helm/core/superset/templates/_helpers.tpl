{{/*

 Licensed to the Apache Software Foundation (ASF) under one or more
 contributor license agreements.  See the NOTICE file distributed with
 this work for additional information regarding copyright ownership.
 The ASF licenses this file to You under the Apache License, Version 2.0
 (the "License"); you may not use this file except in compliance with
 the License.  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

*/}}
{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "superset.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "superset.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "superset.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "superset.fullname" .) .Values.serviceAccountName -}}
{{- else -}}
{{- default "default" .Values.serviceAccountName -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "superset.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "superset-config" }}
from flask_appbuilder.security.manager import AUTH_OID
from keycloak_security_manager import OIDCSecurityManager
import os
from cachelib.redis import RedisCache
from my_security_manager import CustomSecurityManager

import requests

user_search_url = 'https://dev-hcx.swasth.app/api/v0.8/user/search'
participant_search_url = 'https://dev-hcx.swasth.app/api/v0.8/participant/search'
headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICI3Q1l0Z2VYMzA2NEQ3VUU0czdCQWlJZmUzN3hxczBtNEVSQnpmdzVuMzdNIn0.eyJleHAiOjE2OTMwNTYzMzksImlhdCI6MTY5MTMyODMzOSwianRpIjoiMjU2MmIzZGUtYmEzZC00OTAwLThmYTgtNzc0NzYxZWM2Y2Y0IiwiaXNzIjoiaHR0cDovL2Rldi1oY3guc3dhc3RoLmFwcC9hdXRoL3JlYWxtcy9zd2FzdGgtaGN4LXBhcnRpY2lwYW50cyIsInN1YiI6IjU5ZDQzZjliLTQyZTctNDQ4MC05ZWMyLWFhNmJkOTVjY2I1ZiIsInR5cCI6IkJlYXJlciIsImF6cCI6InJlZ2lzdHJ5LWZyb250ZW5kIiwic2Vzc2lvbl9zdGF0ZSI6ImVjMDg5MmM0LWE5YzMtNDA1ZC1iYjY1LWQ0Mzc1YjNiNjE4OCIsImFjciI6IjEiLCJyZWFsbV9hY2Nlc3MiOnsicm9sZXMiOlsiSElFL0hJTy5IQ1giLCJkZWZhdWx0LXJvbGVzLW5kZWFyIl19LCJzY29wZSI6InByb2ZpbGUgZW1haWwiLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsInByZWZlcnJlZF91c2VybmFtZSI6ImhjeGdhdGV3YXlAc3dhc3RoLm9yZyIsImVudGl0eSI6WyJPcmdhbmlzYXRpb24iXSwiZW1haWwiOiJoY3hnYXRld2F5QHN3YXN0aC5vcmcifQ.HWlExZkFpOAtHJeyvaxVf2THKrzPMGkOWdvCa6efFtdpbtN6H4U5SAQVWZQZSffkC5zTgMGulrq3CWBJbkgmqgprImLPpxggdtgfXcS0Yi63YZiBsfcMjAzMcoOVmZ1o3eeGJ6GKgQsJzyzw8_cUcf0t2XdR3UeiRhNuQLecngm6DFecoR_p6VqZ82IIxGd1DeUPy8LLRbD2d3YKmDyGZe5HSDjiM5dumTRdcj1AU1pxoHcjvhwjptXLkRPNuZ9hTfer9y5eOo506CMu7ArPt47cyZsz9A1-otwni5ymhQp7AFxCo0iiAC5Joi7EGouAA0n7C5fJJ3XMvyvKmNhy7w'
}



def get_participant_emails(user_id):
    data = {
      "filters": {
            "user_id": {
               "eq": user_id
        }
      } 
    }

    print(data)

    response = requests.post(user_search_url, headers=headers, json=data)
    if response.status_code == 200:
        result = response.json()
        # Process the result here
        print(result)  

        participant_codes_list = []
        users = result.get('users', [])
        for user in users:
            tenant_roles = user.get('tenant_roles', [])
            codes = [tenant['participant_code'] for tenant in tenant_roles]
            participant_codes_list.extend(codes)  # Append roles to the list

        # Now you can access the roles outside the loop
        print("Participant Codes:", participant_codes_list)
        
        participant_request_filters = {
          "filters": {
            "participant_code": {
               "or": participant_codes_list
          }
         } 
        }
        print("Participant request ", participant_request_filters)
        participant_response = requests.post(participant_search_url, headers=headers, json=participant_request_filters)
        
        if participant_response.status_code == 200:
            participant_result = response.json()
            participants = participant_result.get('participants', [])
            primary_emails = [participant.get('primary_email', None) for participant in participants]
            print("Participant emails ", primary_emails)
            emails_string = ', '.join(f"'{email}'" for email in primary_emails)
            print("Participant Primary Emails " + primary_emails)
            return emails_string
        else:
            print(f"Participant Search Request failed with status code: {response.status_code}")
            print(response.text)    
    else:
        print(f"Request failed with status code: {response.status_code}")
        print(response.text)


from datetime import datetime

def current_datetime():
    return datetime.now().strftime("%Y-%m-%d")

JINJA_CONTEXT_ADDONS = {
    "current_get_participant_emails": get_participant_emails
}

ENABLE_CORS = True
CORS_OPTIONS = {
    'supports_credentials': True,
    'allow_headers': ['*'],
    'resources':['*'],
    'origins': ['*'],
}
ENABLE_PROXY_FIX = True
PUBLIC_ROLE_LIKE_GAMMA = True
SESSION_COOKIE_SAMESITE = "None"
SESSION_COOKIE_SECURE = True 
SESSION_COOKIE_HTTPONLY = True
def env(key, default=None):
    return os.getenv(key, default)

MAPBOX_API_KEY = env('MAPBOX_API_KEY', '')
CACHE_CONFIG = {
      'CACHE_TYPE': 'redis',
      'CACHE_DEFAULT_TIMEOUT': 300,
      'CACHE_KEY_PREFIX': 'superset_',
      'CACHE_REDIS_HOST': env('REDIS_HOST'),
      'CACHE_REDIS_PORT': env('REDIS_PORT'),
      'CACHE_REDIS_PASSWORD': env('REDIS_PASSWORD'),
      'CACHE_REDIS_DB': env('REDIS_DB', 1),
}
DATA_CACHE_CONFIG = CACHE_CONFIG

SQLALCHEMY_DATABASE_URI = f"postgresql+psycopg2://{env('DB_USER')}:{env('DB_PASS')}@{env('DB_HOST')}:{env('DB_PORT')}/{env('DB_NAME')}"
SQLALCHEMY_TRACK_MODIFICATIONS = True
SECRET_KEY = env('SECRET_KEY', 'thisISaSECRET_1234')

TALISMAN_CONFIG = {
"content_security_policy": "None",
"force_https": False,
"force_https_permanent": False,
}
CSRF_ENABLED = False
# Flask-WTF flag for CSRF
WTF_CSRF_ENABLED = False
# Add endpoints that need to be exempt from CSRF protection
WTF_CSRF_EXEMPT_LIST = []
# A CSRF token that expires in 1 year
WTF_CSRF_TIME_LIMIT = 60 * 60 * 24 * 365
class CeleryConfig(object):
  CELERY_IMPORTS = ('superset.sql_lab', )
  CELERY_ANNOTATIONS = {'tasks.add': {'rate_limit': '10/s'}}
{{- if .Values.supersetNode.connections.redis_password }}
  BROKER_URL = f"redis://:{env('REDIS_PASSWORD')}@{env('REDIS_HOST')}:{env('REDIS_PORT')}/0"
  CELERY_RESULT_BACKEND = f"redis://:{env('REDIS_PASSWORD')}@{env('REDIS_HOST')}:{env('REDIS_PORT')}/0"
{{- else }}
  BROKER_URL = f"redis://{env('REDIS_HOST')}:{env('REDIS_PORT')}/0"
  CELERY_RESULT_BACKEND = f"redis://{env('REDIS_HOST')}:{env('REDIS_PORT')}/0"
{{- end }}

CELERY_CONFIG = CeleryConfig
RESULTS_BACKEND = RedisCache(
      host=env('REDIS_HOST'),
{{- if .Values.supersetNode.connections.redis_password }}
      password=env('REDIS_PASSWORD'),
{{- end }}
      port=env('REDIS_PORT'),
      key_prefix='superset_results'
)
# OIDC config
#AUTH_TYPE = AUTH_OID
OIDC_CLIENT_SECRETS = '/app/pythonpath/client_secret.json'
OIDC_ID_TOKEN_COOKIE_SECURE = False
OIDC_REQUIRE_VERIFIED_EMAIL = False
OIDC_OPENID_REALM = env('OIDC_OPENID_REALM')
# OIDC_INTROSPECTION_AUTH_METHOD = 'client_secret_post'
CUSTOM_SECURITY_MANAGER = CustomSecurityManager
AUTH_USER_REGISTRATION = True
AUTH_USER_REGISTRATION_ROLE = 'Gamma'
APP_NAME = env('APP_NAME')
{{ if .Values.configOverrides }}
# Overrides
{{- range $key, $value := .Values.configOverrides }}
# {{ $key }}
{{ tpl $value $ }}
{{- end }}
{{- end }}
{{ if .Values.configOverridesFiles }}
# Overrides from files
{{- $files := .Files }}
{{- range $key, $value := .Values.configOverridesFiles }}
# {{ $key }}
{{ $files.Get $value }}
{{- end }}
{{- end }}

{{- end }}
