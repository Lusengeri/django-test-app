import React from "react";
import PropTypes from 'prop-types'

const Button = ( {color, text, onAdd}) => {
    return(
        <button className="btn" style = { { backgroundColor: color}} onClick={onAdd}>{text}</button>
    )
}

export default Button;

Button.defaultProps = {
    color: 'grey',
}

Button.propTypes = {
    text: PropTypes.string.isRequired,
    color: PropTypes.string
}