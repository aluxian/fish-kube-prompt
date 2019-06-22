# Inspired from:
# https://github.com/jonmosco/kube-ps1
# https://github.com/Ladicle/fish-kubectl-prompt

set -g color_ctx (set_color $KUBE_PROMPT_COLOR_CTX)
set -g color_ns (set_color $KUBE_PROMPT_COLOR_NS)

function __kube_ps_update_cache
  function __kube_ps_cache_context
    set -l ctx (kubectl config current-context 2>/dev/null)
    if /bin/test $status -eq 0
      set -g __kube_ps_context "$color_ctx$ctx"
    else
      set -g __kube_ps_context "n/a"
    end
  end

  function __kube_ps_cache_namespace
    set -l ns (kubectl config view --minify -o 'jsonpath={..namespace}' 2>/dev/null)
    if /bin/test -n "$ns"
      set -g __kube_ps_namespace "$color_ns$ns"
    else
      set -g __kube_ps_namespace "default"
    end
  end

  set -l kubeconfig "$KUBECONFIG"
  if /bin/test -z "$kubeconfig"
    set kubeconfig "$HOME/.kube/config"
  end

  if /bin/test "$kubeconfig" != "$__kube_ps_kubeconfig"
    __kube_ps_cache_context
    __kube_ps_cache_namespace
    set -g __kube_ps_kubeconfig "$kubeconfig"
    set -g __kube_ps_timestamp (date +%s)
    return
  end

  for conf in (string split ':' "$kubeconfig")
    if /bin/test -r "$conf"
      if /bin/test -z "$__kube_ps_timestamp"; or /bin/test (/usr/bin/stat -f '%m' "$conf") -gt "$__kube_ps_timestamp"
        __kube_ps_cache_context
        __kube_ps_cache_namespace
        set -g __kube_ps_kubeconfig "$kubeconfig"
        set -g __kube_ps_timestamp (date +%s)
        return
      end
    end
  end
end

function __kube_prompt
  if /bin/test -z "$__kube_ps_enabled"; or /bin/test $__kube_ps_enabled -ne 1
    return
  end

  __kube_ps_update_cache
  echo -n -s " (⎈ $__kube_ps_context|$__kube_ps_namespace)"
end

