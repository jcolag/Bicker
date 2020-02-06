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
        <span
          dangerouslySetInnerHTML={ html }
          offset={this.props.offset}
          pid={this.props.pid}
        >
        </span>
      </React.Fragment>
    );
  }
}

ClauseSpan.propTypes = {
  offset: PropTypes.number,
  pid: PropTypes.number,
  text: PropTypes.string,
};
export default ClauseSpan
