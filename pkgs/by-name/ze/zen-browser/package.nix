{
  wrapFirefox,
  zen-browser-unwrapped,
}:

wrapFirefox zen-browser-unwrapped {
  pname = "zen-browser";

  extraPolicies = {
    DisableAppUpdate = true;
  };
}
