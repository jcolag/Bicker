import React from "react";
import PropTypes from "prop-types";
import ReplyForm from "./ReplyForm";

class PuncButton extends React.Component {
  asMarkup(text) {
    return { __html: text };
  }
  
  render () {
    const html = this.asMarkup(this.props.punc);
    return (
      <React.Fragment>
        <a
          className='punctuation-button'
          href='javascript:void(0)'
          name={this.props.count}
          onClick={toggleReplyForm}
          title="Click to reply here"
        >
          <span
            name={this.props.count}
            dangerouslySetInnerHTML={ html }
          />
        </a>
        <ReplyForm count={ this.props.count } />
      </React.Fragment>
    );
  }
}

PuncButton.propTypes = {
  count: PropTypes.number,
  punc: PropTypes.string,
};
export default PuncButton
