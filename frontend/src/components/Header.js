import React from "react";
import Button from "./Button";
import PropTypes from "prop-types"
import { useLocation } from "react-router";

const Header = ( { title, onAdd, showAddTask}) => {
    const location = useLocation()
    return (
        <header className='header'>
            <h1>{title}</h1>
            {location.pathname === '/' && <Button text={ showAddTask ? "Close" : "Add"} colour={showAddTask ? 'red': 'green'} onAdd={onAdd}/>}
        </header>
    )
}

Header.defaultProps = {
    title: "Task Tracker"
}

Header.propTypes = {
    title: PropTypes.string,
}

export default Header;