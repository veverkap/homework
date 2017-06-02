// this holds the list of members in the household
var householdMembers = [];

// Add an event listener for submitting the form to handle validation
var mainForm = document.forms[0];
mainForm.addEventListener("submit", captureFormEvent, true);

// Add an event listener for submitting the form to handle validation
var addButton = getClassElement("add");
addButton.addEventListener("click", addMember, true);

var ageInput = getNamedElement("age");
var relationshipDropDown = getNamedElement("rel");
var smokerCheckBox = getNamedElement("smoker");
var householdList = getClassElement("household");
var debug = getClassElement("debug");

function logMessage(msg) {
  if (console.log) {
    console.log(msg)
  }
}


function getNamedElement(name) {
  logMessage("getNamedElement -> " + name);
  return document.getElementsByName(name)[0];
}

function getClassElement(className) {
  logMessage("getClassElement -> " + className);
  return document.getElementsByClassName(className)[0];
}

function captureFormEvent(event) {
  logMessage("captureFormEvent -> click");
  debug.innerText = JSON.stringify(householdMembers);
  debug.style.display = "block";
  event.preventDefault();
}

function addMember(event) {
  logMessage("addMember -> click");
  event.preventDefault();

  var valid = true;
  var age = parseInt(ageInput.value, 10);
  var relationship = relationshipDropDown.value;
  var smoker = smokerCheckBox.checked;
  var age_error = document.getElementById("age_error");
  var relationship_error = document.getElementById("relationship_error");

  if (!Number.isInteger(age) || age == 0) {
    logMessage("addMember -> age " + age + " is not valid");
    if (age_error == undefined) {
      ageInput.style.border = "solid #a94442";
      
      var div = document.createElement("div");
      div.id = "age_error";
      div.style.color = "#a94442";
      div.innerHTML = "Age Must Be Greater Than Zero";
      mainForm.insertBefore(div, mainForm.childNodes[0]);
    }
    valid = false;
  } else {
    logMessage("addMember -> age " + age + " is valid");
    if (age_error != undefined) {
      mainForm.removeChild(age_error);
      ageInput.style.border = "";
    }
  }

  if (relationship.length == 0) {
    logMessage("addMember -> relationship " + relationship + " is not valid");
    if (relationship_error == undefined) {
      relationshipDropDown.style.border = "solid #a94442";

      var div = document.createElement("div");
      div.id = "relationship_error";
      div.style.color = "#a94442";
      div.innerHTML = "Relationship Must Be Selected";
      mainForm.insertBefore(div, mainForm.childNodes[0]);
    }
    valid = false;
  } else {
    logMessage("addMember -> relationship " + relationship + " is valid");
    if (relationship_error != undefined) {
      mainForm.removeChild(relationship_error);
      relationshipDropDown.style.border = "";
    }
  }

  if (valid) {
    var newMember = {age: age, relationship: relationship, smoker: smoker};
    logMessage("addMember -> valid member, adding " + JSON.stringify(newMember));
    householdMembers.push(newMember);
    ageInput.value = "";
    relationshipDropDown.selectedIndex = 0;
    smokerCheckBox.checked = false;
    renderHousehold();
    return true;
  } else {
    return false;
  }
}

function remove(i) {
  logMessage("remove -> removing member at index " + i);
  var removed = householdMembers.splice(i, 1);
  logMessage("remove -> removed  " + JSON.stringify(removed[0]));
  window.event.preventDefault();
  renderHousehold();
  return false;
}

function renderHousehold() {
  logMessage("renderHousehold -> resetting householdList");
  householdList.innerHTML = "";

  logMessage("renderHousehold -> adding " + householdMembers.length + " members");
  for (i = 0; i < householdMembers.length; i++) { 
    var member = householdMembers[i];
    var text = "Relationship: " + member.relationship + " / Age: " + member.age + " / Smoker?: " + member.smoker + " <a href=\"\" onclick=\"remove(" + i + ");\">Remove</a>";
    var listItem = document.createElement("li");
    listItem.id = "member_" + i;
    listItem.innerHTML = text;
    householdList.appendChild(listItem);    
  }  
}