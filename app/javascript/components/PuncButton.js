import React from "react";
import PropTypes from "prop-types";
import ReplyForm from "./ReplyForm";

class PuncButton extends React.Component {
  asMarkup(text) {
    return { __html: text };
  }

  render () {
    const html = this.asMarkup(this.props.punc);
    const name = `${this.props.pnumber}-${this.props.count}`;
    return (
      <React.Fragment>
        <a
          className='punctuation-button'
          name={name}
          offset={this.props.offset}
          onClick={toggleReplyForm}
          title="Click to reply here"
        >
          <span
            dangerouslySetInnerHTML={ html }
            name={name}
            offset={this.props.offset}
          />
        </a>
        <ReplyForm
          count={ this.props.count }
          offset={this.props.offset}
          pid={this.props.pid}
          pnumber={ this.props.pnumber }
        />
      </React.Fragment>
    );
  }
}

PuncButton.propTypes = {
  count: PropTypes.number,
  offset: PropTypes.number,
  pid: PropTypes.number,
  pnumber: PropTypes.number,
  punc: PropTypes.string,
};
export default PuncButton
