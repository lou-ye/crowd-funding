// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract CrowdFunding {
    enum FundraisingState { Opened, Closed }

    struct Contribution {
        address contributor;
        uint value;
    }

    struct Project {
        string id;
        string name;
        string description;
        address payable author;
        FundraisingState state;
        uint funds;
        uint fundraisingGoal;
    }

    Project[] public projects;
    mapping(string => Contribution[]) public contributions;

    event ProjectCreated(
        string id,
        string name,
        string description,
        uint fundraisingGoal
    );

    event ProjectFunded(
        string projectId,
        string projectName,
        uint value
    );

    event ProjectStateChanged(
        string projectId,
        string projectName,
        FundraisingState state
    );

    modifier isAuthor(uint projectIndex) {
        require(projects[projectIndex].author == msg.sender, "You need to be the project author. ");
        _;
    }

    modifier isNotAuthor(uint projectIndex) {
        require(projects[projectIndex].author != msg.sender, "As author you can not fund your own project. ");
        _;
    }

    function createProject(string calldata id, string calldata name, string calldata description, uint fundraisingGoal) public {
        require(fundraisingGoal > 0, "Fundraising goal must be greater than 0. ");
        Project memory project = Project(id, name, description, payable(msg.sender), FundraisingState.Opened, 0, fundraisingGoal);
        projects.push(project);
        emit ProjectCreated(id, name, description, fundraisingGoal);
    }

    function fundProject(uint projectIndex) public payable isNotAuthor(projectIndex) {
        Project memory project = projects[projectIndex];
        require(project.state != FundraisingState.Closed, "The project can not receive funds. ");
        require(msg.value > 0, "Fund value must be greater than 0. ");
        project.author.transfer(msg.value);
        project.funds += msg.value;
        projects[projectIndex] = project;
        contributions[project.id].push(Contribution(msg.sender, msg.value));
        emit ProjectFunded(project.id, project.name, msg.value);
    }    

    function changeProjectState(FundraisingState newState, uint projectIndex) public isAuthor(projectIndex) {
        Project memory project = projects[projectIndex];
        require(project.state != newState, "The new state must be different. ");
        project.state = newState;
        projects[projectIndex] = project;
        emit ProjectStateChanged(project.id, project.name, newState);
    }   
}