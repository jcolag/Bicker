import React from "react";
import PropTypes from "prop-types";

class ClauseSpan extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      clause: this.props.clause,
      offset: this.props.offset,
      pid: this.props.pid,
    };
  }

  asMarkup(text) {
    return { __html: text };
  }

  render () {
    const html = this.asMarkup(this.state.clause);
    return (
      <React.Fragment>
        <span
          dangerouslySetInnerHTML={ html }
          offset={this.state.offset}
          pid={this.state.pid}
        >
        </span>
      </React.Fragment>
    );
  }
}

ClauseSpan.propTypes = {
  clause: PropTypes.string,
  offset: PropTypes.number,
  pid: PropTypes.number,
};
export default ClauseSpan
