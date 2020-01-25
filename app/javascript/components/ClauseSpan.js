import React from "react";
import PropTypes from "prop-types";

class ClauseSpan extends React.Component {
  asMarkup(text) {
    return { __html: text };
  }
  
  render () {
    const html = this.asMarkup(this.props.clause);
    return (
      <React.Fragment>
        <span dangerouslySetInnerHTML={ html } >
        </span>
      </React.Fragment>
    );
  }
}

ClauseSpan.propTypes = {
  text: PropTypes.string,
};
export default ClauseSpan
